CC = gcc
CFLAGS = Wall

all: expressions.o proc-common.o tree.o
	$(CC) -$(CFLAGS) expressions.o proc-common.o tree.o -o expressions

proc-common.o: proc-common.c
	$(CC) -$(CFLAGS) -c proc-common.c

expressions.o: expressions.c
	$(CC) -$(CFLAGS) -c expressions.c

tree.o: tree.c
	$(CC) -$(CFLAGS) -c tree.c

clean:
	rm expressions.o proc-common.o tree.o expressions