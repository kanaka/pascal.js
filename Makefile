TESTDIR ?= tests
BUILDDIR ?= build
RUNLL ?= ./runll
RUNFPC ?= ./runfpc

TESTS ?= write1 write2 \
	 expr1 expr2 \
	 float1 \
	 bool1 \
	 char1 \
	 const1 const2 \
	 type1 type2 type3 \
	 proc1 proc2 proc3 proc4 proc5 pfib \
	 func1 ffib \
	 string1 string2 \
	 if1 if2 \
	 nested1 nested2 nested3 nested4 \
	 for1 for2 repeat1 while1 while2 \
	 array1 array2 array4 array5 array6 array7 \
	 record1 record2 record3 record4 \
	 book9-4 \
	 qsort \
	 delay clrscr1 gotoxy1 keypressed1 \
	 random1 random2

all: parse.js libs/kbd.js

clean:
	rm -f $(BUILDDIR)/* parse.js
	rm -f libs/kbd.ll libs/kbd.js

parse.js: parse.jison
	jison parse.jison

libs/kbd.js: libs/kbd.ll
	echo "Munging $< into $@"
	@echo "var llvm_ir = [" > $@; \
	egrep -v "^target |declare.*@printf" $< | \
	    sed -e "s@\\\\@\\\\\\\\@g" \
	        -e "s/'/\\\\'/g" \
		-e "s/^/'/" \
		-e "s/$$/',/" >> $@; \
	echo "];" >> $@; \
	echo "exports.llvm_ir = llvm_ir;" >> $@

libs/kbd.ll: libs/kbd.c
	clang -emit-llvm $< -S -o $@


TEST_DEPS = ir.js parse.js libs/system.js libs/crt.js libs/kbd.js

FPC_OBJECTS=$(TESTS:%=$(BUILDDIR)/%)
LL_OBJECTS=$(TESTS:%=$(BUILDDIR)/%.ll)
FPC_OUTPUT=$(TESTS:%=$(BUILDDIR)/%.out1)
LL_OUTPUT=$(TESTS:%=$(BUILDDIR)/%.out2)

DIFFS=$(TESTS:%=$(BUILDDIR)/%.diff)

$(FPC_OBJECTS): $(BUILDDIR)/%: $(TESTDIR)/%.pas $(TEST_DEPS)
	@if [ -e $<.out ]; then \
	    cp $<.out $@.out1; \
	    touch $@.skip; \
	else \
	    echo 'fpc -FE$(BUILDDIR) $< | egrep -v "Compiler version|Copyright|Target OS"'; \
	    fpc -FE$(BUILDDIR) $< | egrep -v "Compiler version|Copyright|Target OS"; \
	fi

$(LL_OBJECTS): $(BUILDDIR)/%.ll: $(TESTDIR)/%.pas $(TEST_DEPS)
	node ir.js $< > $@

# run the fpc executable translating floating point output
$(FPC_OUTPUT): $(BUILDDIR)/%.out1: $(BUILDDIR)/%
	@if [ ! -e $<.skip ]; then \
	    if [ -e $(TESTDIR)/$*.pas.in ]; then \
		echo '$(TESTDIR)/$*.pas.in | $(RUNFPC) $< > $@'; \
		cat $(TESTDIR)/$*.pas.in | $(RUNFPC) $< > $@; \
	    else \
		echo '$(RUNFPC) $< > $@'; \
		$(RUNFPC) $< > $@; \
	    fi; \
	fi	

$(LL_OUTPUT): $(BUILDDIR)/%.out2: $(BUILDDIR)/%.ll
	@if [ -e $(TESTDIR)/$*.pas.in ]; then \
	    echo 'cat $(TESTDIR)/$*.pas.in | $(RUNLL) $< > $@'; \
	    cat $(TESTDIR)/$*.pas.in | $(RUNLL) $< > $@; \
	else \
	    echo '$(RUNLL) $< > $@'; \
	    $(RUNLL) $< > $@; \
	fi

$(DIFFS): $(BUILDDIR)/%.diff: $(BUILDDIR)/%.out1 $(BUILDDIR)/%.out2
	diff -u $^ > $@


test_prefix:
	@echo "Building tests: $(TESTS)"

test: test_prefix $(DIFFS)
	@set -e; \
	mkdir -p $(BUILDDIR); \
	pass=""; \
	fail=""; \
	tests="$(TESTS)"; \
	for test in $$tests; do \
	    diffs=`cat $(BUILDDIR)/$${test}.diff`; \
	    if [ -z "$${diffs}" ]; then \
	        pass="$${pass}$${test} "; \
	    else \
		echo "Output differences for test $${test}:"; \
		echo -e "$${diffs}"; \
	        fail="$${fail}$${test} "; \
	    fi; \
	done; \
	echo "RESULT: `echo $$pass | wc -w`/`echo $$tests | wc -w` tests passed"; \
	[ -n "$${fail}" ] && echo "Failing tests: $${fail}"; \
	true
