files := main.c mathParse.cbl calculate.cbl
ofiles := $(subst .c,.o,$(subst .cbl,.o,$(files)))

main: $(ofiles)
	cobc -O2 -g -x -o main $(ofiles) -fstatic-call -lcob -ldiscord -lcurl

%.o: %.c
	gcc -Wall -c $<
%.o: %.cbl
	cobc -Wall -F -fimplicit-init -c $<

clean:
	rm -f main $(ofiles)
