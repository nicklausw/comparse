main: main.o test.o
	cobc -g -x -o main main.o test.o -lcob -ldiscord -lcurl

main.o: main.c
	gcc -g -c -DBOT_TOKEN=\"${LESLIE_TOKEN}\" -o main.o main.c -pthread -ldiscord -lcurl

test.o: test.cbl
	cobc -g -c -o test.o test.cbl

clean:
	rm -f main main.o test.o