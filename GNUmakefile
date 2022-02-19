cblfiles := mathParse.cbl calculate.cbl
cfiles := main.c
ofiles := $(subst .c,.o,$(subst .cbl,.o,$(cblfiles) $(cfiles)))
# files only made with -g
gfiles := $(subst .cbl,.c,$(cblfiles)) \
	  $(subst .cbl,.c.l.h,$(cblfiles)) \
	  $(subst .cbl,.c.h,$(cblfiles)) \
	  $(subst .cbl,.i,$(cblfiles))

main: $(ofiles)
	gcc -O2 -o main $(ofiles) -pthread -lcob -ldiscord -lcurl

%.o: %.c
	gcc -Wall -c $< -o $@
%.o: %.cbl
	cobc -Wall -F -fimplicit-init -fstatic-call -c $< -o $@

clean:
	rm -f main $(ofiles) $(gfiles)
