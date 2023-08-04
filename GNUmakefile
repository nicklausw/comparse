cblfiles := math_parse.cbl calculate.cbl
cfiles := main.c
ofiles := $(subst .c,.o,$(subst .cbl,.o,$(cblfiles) $(cfiles)))
# files only made with -g
gfiles := $(subst .cbl,.c,$(cblfiles)) \
	  $(subst .cbl,.c.l.h,$(cblfiles)) \
	  $(subst .cbl,.c.h,$(cblfiles)) \
	  $(subst .cbl,.i,$(cblfiles))
flags := -O2 -Wall
cblflags := -Wno-others

comparse: $(ofiles)
	cobc $(flags) -x -o comparse $(ofiles) -lmpfr -lgmp -lcob -ldiscord -lcurl -lpthread

%.o: %.c
	$(CC) $(flags) -c $< -o $@
%.o: %.cbl
	cobc $(flags) $(cblflags) -Wall -F -fimplicit-init -fstatic-call -c $< -o $@

clean:
	rm -f comparse $(ofiles) $(gfiles)
