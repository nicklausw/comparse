cblfiles := math_parse.cbl calculate.cbl slide_back.cbl reduce_parentheses.cbl
cfiles := main.c
ofiles := $(cblfiles:.cbl=.o) $(cfiles:.c=.o)
# files only made with -g
gfiles := $(cblfiles:.cbl=.c) \
		  $(cblfiles:.cbl=.c.l.h) \
		  $(cblfiles:.cbl=.c.h) \
		  $(cblfiles:.cbl=.i)
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
