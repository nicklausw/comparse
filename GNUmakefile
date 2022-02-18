files := main.c mathParse.cbl calculate.cbl
ofiles := $(subst .c,.o,$(subst .cbl,.o,$(files)))

main: $(ofiles)
	gcc -O2 -g -o main $(ofiles) -pthread -lcob -ldiscord -lcurl

%.o: %.c
	gcc -g -Wall -c $<
%.o: %.cbl
	cobc -g -Wall -F -fimplicit-init -fstatic-call -c $<

clean:
	rm -f main $(ofiles)
