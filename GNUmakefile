files := main.c symbolType.cbl mathParse.cbl

main: $(files)
	cobc -g -x -o main $(files) -fstatic-call -lcob -ldiscord -lcurl

clean:
	rm -f main
