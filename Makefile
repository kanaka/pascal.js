TESTDIR ?= tests
BUILDDIR ?= build

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
	 for1 for2 \
	 array1 array2 array4 array5 array6 array7 \
	 record1 record2 record3 record4 \
	 book9-4 \
	 qsort \
	 delay \
	 random1 random2

all: parse.js

parse.js: parse.jison
	jison parse.jison

clean:
	rm $(BUILDDIR)/* parse.js


TEST_DEPS = ir.js parse.js libs/system.js libs/crt.js

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
	    echo '$< | sed 's/\(\.[0-9][0-9][0-9][0-9][0-9][0-9]\)[0-9]*\(E[+-]\)0*\([0-9][0-9]\)/\1\2\3/g' > $@'; \
	    $< | sed 's/\(\.[0-9][0-9][0-9][0-9][0-9][0-9]\)[0-9]*\(E[+-]\)0*\([0-9][0-9]\)/\1\2\3/g' > $@; \
	fi	

$(LL_OUTPUT): $(BUILDDIR)/%.out2: $(BUILDDIR)/%.ll
	lli $< > $@

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
