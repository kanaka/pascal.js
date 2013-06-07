TESTS ?= proc1 proc2 proc3 proc4 proc5 \
	 expr1 \
	 if1 if2 \
	 nested1 nested2 \
	 write1 write2 \
	 for1 for2 \
	 book9-4 pfib

all:
	jison parse.jison

test:
	@set -e; \
	mkdir -p build; \
	for test in $(TESTS); do \
	    echo "Testing $${test}"; \
	    fpc -FEbuild tests/$${test}.pas | egrep -v "Compiler version|Copyright|Target OS"; \
	    build/$${test} > build/$${test}.out1; \
	    node ir.js tests/$${test}.pas > build/$${test}.ll; \
	    lli build/$${test}.ll > build/$${test}.out2; \
	    if ! cmp build/$${test}.out1 build/$${test}.out2; then \
		echo "Output differences for test $${test}:"; \
		diff -u build/$${test}.out1 build/$${test}.out2; \
	    fi; \
	done
