TESTDIR ?= tests

TESTS ?= proc1 proc2 proc3 proc4 proc5 pfib \
	 func1 ffib \
	 expr1 \
	 bool1 \
	 if1 if2 \
	 nested1 nested2 nested3 \
	 write1 write2 \
	 for1 for2 \
	 book9-4

all:
	jison parse.jison

test:
	@set -e; \
	mkdir -p build; \
	for test in $(TESTS); do \
	    echo "Testing $${test}"; \
	    fpc -FEbuild $(TESTDIR)/$${test}.pas | egrep -v "Compiler version|Copyright|Target OS"; \
	    build/$${test} > build/$${test}.out1; \
	    node ir.js $(TESTDIR)/$${test}.pas > build/$${test}.ll; \
	    lli build/$${test}.ll > build/$${test}.out2; \
	    if ! cmp build/$${test}.out1 build/$${test}.out2; then \
		echo "Output differences for test $${test}:"; \
		diff -u build/$${test}.out1 build/$${test}.out2; \
	    fi; \
	done; \
	echo "Ran all $(words $(TESTS)) tests successfully"
