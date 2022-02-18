files := main.c mathParse.cbl
ofiles := $(subst .c,.o,$(subst .cbl,.o,$(files)))

main: $(ofiles)
	cobc -g -x -o main $(ofiles) -fstatic-call -lcob -ldiscord -lcurl

%.o: %.c
	gcc -c $<
%.o: %.cbl
	cobc -c $<

clean:
	rm -f main $(ofiles)
