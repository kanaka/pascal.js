TESTDIR ?= tests
BUILDDIR ?= build
RUNLL ?= ./runll
RUNFPC ?= ./runfpc

TESTS ?= semi1 \
	 write1 write2 write3 \
	 read1 read2 read3 read4 \
	 expr1 expr2 \
	 float1 float2 \
	 bool1 \
	 char1 char2 \
	 const1 const2 \
	 type1 type2 type3 \
	 proc1 proc2 proc3 proc4 proc5 \
	 func1 \
	 string1 string2 string3 string4 string5 string6 string7 string8 string9 \
	 array1 array2 array3 array4 array5 array6 array7 \
	 record1 record2 record3 record4 \
	 deref1 deref2 deref3 \
	 if1 if2 \
	 nested1 nested2 nested3 nested4 \
	 for1 for2 repeat1 while1 while2 \
	 halt \
	 delay clrscr1 gotoxy1 keypressed1 keypressed2 box \
	 random1 random2 \
	 \
	 pfib ffib area qsort \
	 book9-4 \
	 \
	 fail_param1 fail_param2 fail_param3 fail_param4 \
	 fail_func1 fail_func2


all: parse.js units/kbd.js

clean:
	rm -f $(BUILDDIR)/* parse.js
	rm -f units/kbd.ll units/kbd.js

parse.js: parse.jison
	jison parse.jison

# Remove declarations that will also be declared in units
units/kbd.js: units/kbd.ll
	echo "Munging $< into $@"
	@echo "var llvm_ir = [" > $@; \
	egrep -v "^target |^@stdout =|declare.*@malloc|declare.*@fflush|declare.*@printf|struct._IO_FILE =" $< | \
	    sed -e "s@\\\\@\\\\\\\\@g" \
	        -e "s/'/\\\\'/g" \
		-e "s/^/'/" \
		-e "s/$$/',/" >> $@; \
	echo "];" >> $@; \
	echo "exports.llvm_ir = llvm_ir;" >> $@

units/kbd.ll: units/kbd.c
	clang -emit-llvm $< -S -o $@


TEST_DEPS = ir.js parse.js units/system.js units/crt.js units/kbd.js

GOOD_TESTS=$(filter-out fail_%,$(TESTS))
FAIL_TESTS=$(filter fail_%,$(TESTS))

FPC_OBJECTS=$(GOOD_TESTS:%=$(BUILDDIR)/%.1)
LL_OBJECTS=$(GOOD_TESTS:%=$(BUILDDIR)/%.2)
FPC_OUTPUT=$(GOOD_TESTS:%=$(BUILDDIR)/%.out1)
LL_OUTPUT=$(GOOD_TESTS:%=$(BUILDDIR)/%.out2)

DIFFS=$(GOOD_TESTS:%=$(BUILDDIR)/%.diff)
FAIL_MARKS=$(FAIL_TESTS:%=$(BUILDDIR)/%.fail-msg)


$(FPC_OBJECTS): $(BUILDDIR)/%.1: $(TESTDIR)/%.pas $(TEST_DEPS)
	@if [ -e $<.out ]; then \
	    cp $<.out $(BUILDDIR)/$*.out1; \
	    touch $@.skip; \
	else \
	    echo 'fpc -FE$(BUILDDIR) -o$*.1 $< | egrep -v "Compiler version|Copyright|Target OS"'; \
	    fpc -FE$(BUILDDIR) -o$*.1 $< | egrep -v "Compiler version|Copyright|Target OS"; \
	fi

$(LL_OBJECTS): $(BUILDDIR)/%.2: $(TESTDIR)/%.pas $(TEST_DEPS)
	node compile_native.js $< $@

$(FAIL_MARKS): $(BUILDDIR)/%.fail-msg: $(TESTDIR)/%.pas $(TEST_DEPS)
	@echo "Verifying that $< fails"; \
	out=`node compile_native.js $< /dev/null 2>&1`; \
	if [ $$? = 0 ]; then \
	    echo "$< should have failed but did not"; \
	else \
	    echo "$${out}" > $@; \
	fi

# run the fpc executable translating floating point output
$(FPC_OUTPUT): $(BUILDDIR)/%.out1: $(BUILDDIR)/%.1
	@if [ ! -e $<.skip ]; then \
	    if [ -e $(TESTDIR)/$*.pas.in ]; then \
		echo '$(TESTDIR)/$*.pas.in | $(RUNFPC) $< > $@'; \
		cat $(TESTDIR)/$*.pas.in | $(RUNFPC) $< > $@; \
	    else \
		echo '$(RUNFPC) $< > $@'; \
		$(RUNFPC) $< > $@; \
	    fi; \
	fi	

$(LL_OUTPUT): $(BUILDDIR)/%.out2: $(BUILDDIR)/%.2
	@if [ -e $(TESTDIR)/$*.pas.in ]; then \
	    echo 'cat $(TESTDIR)/$*.pas.in | $(RUNLL) $< > $@'; \
	    cat $(TESTDIR)/$*.pas.in | $(RUNLL) $< > $@; \
	else \
	    echo '$(RUNLL) $< > $@'; \
	    $(RUNLL) $< > $@; \
	fi

$(DIFFS): $(BUILDDIR)/%.diff: $(BUILDDIR)/%.out1 $(BUILDDIR)/%.out2
	d=`diff -u $^` && echo "$${d}" > $@

test_prefix:
	@echo "Building tests: $(TESTS)"

test: test_prefix $(DIFFS) $(FAIL_MARKS)
	@set -e; \
	pass=""; \
	fail=""; \
	tests="$(GOOD_TESTS)"; \
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
	tests="$(FAIL_TESTS)"; \
	for test in $$tests; do \
	    if [ -e "$(BUILDDIR)/$${test}.fail-msg" ]; then \
	        pass="$${pass}$${test} "; \
	    else \
	        fail="$${fail}$${test} "; \
	    fi; \
	done; \
	echo "RESULT: `echo $$pass | wc -w`/`echo $(TESTS) | wc -w` tests passed"; \
	[ -n "$${fail}" ] && echo "Failing tests: $${fail}"; \
	true

