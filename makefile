COPT = -O2 -DNDEBUG

CWARNS = -Wall -Wextra -pedantic \
        -Waggregate-return \
	-Wbad-function-cast \
        -Wcast-align \
        -Wcast-qual \
	-Wdeclaration-after-statement \
	-Wdisabled-optimization \
        -Wmissing-prototypes \
        -Wnested-externs \
        -Wpointer-arith \
        -Wshadow \
	-Wsign-compare \
	-Wstrict-prototypes \
	-Wundef \
        -Wwrite-strings \
	#  -Wunreachable-code \


CFLAGS = $(CWARNS) $(COPT) -ansi

listlpeg.so: lpeg.c
	luarocks make listlpeg-scm-1.rockspec

test: test.lua list.lua
	lua -l luarocks.require test.lua
	lua -l luarocks.require list.lua

dist:
	git archive --format=tar --prefix=listlpeg-scm/ HEAD | gzip > listlpeg-scm.tar.gz
	scp listlpeg-scm.tar.gz mascarenhas@139.82.100.4:public_html/

clean:
	rm listlpeg.so lpeg.o
