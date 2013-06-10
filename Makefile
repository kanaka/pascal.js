TESTDIR ?= tests
BUILDDIR ?= build

TESTS ?= proc1 proc2 proc3 proc4 proc5 pfib \
	 func1 ffib \
	 expr1 \
	 bool1 \
	 string1 string2 \
	 if1 if2 \
	 nested1 nested2 nested3 \
	 write1 write2 \
	 for1 for2 \
	 array1 array2 array3 \
	 book9-4

FPC_OBJECTS=$(TESTS:%=$(BUILDDIR)/%)
LL_OBJECTS=$(TESTS:%=$(BUILDDIR)/%.ll)
FPC_OUTPUT=$(TESTS:%=$(BUILDDIR)/%.out1)
LL_OUTPUT=$(TESTS:%=$(BUILDDIR)/%.out2)

DIFFS=$(TESTS:%=$(BUILDDIR)/%.diff)

all:
	jison parse.jison

clean:
	rm $(BUILDDIR)/*

$(FPC_OBJECTS): $(BUILDDIR)/%: $(TESTDIR)/%.pas
	fpc -FE$(BUILDDIR) $< | egrep -v "Compiler version|Copyright|Target OS"; \

$(LL_OBJECTS): $(BUILDDIR)/%.ll: $(TESTDIR)/%.pas
	node ir.js $< > $@

$(FPC_OUTPUT): $(BUILDDIR)/%.out1: $(BUILDDIR)/%
	$< > $@

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
	for test in $(TESTS); do \
	    diffs=`cat $(BUILDDIR)/$${test}.diff`; \
	    if [ -z "$${diffs}" ]; then \
	        pass="$${pass}$${test} "; \
	    else \
		echo "Output differences for test $${test}:"; \
		echo -e "$${diffs}"; \
	        fail="$${fail}$${test} "; \
	    fi; \
	done; \
	[ -z "$${fail}" ] && echo "All tests passed"; \
	[ -n "$${fail}" ] && echo "Failing tests: $${fail}"; \
	true
