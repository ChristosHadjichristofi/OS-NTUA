CC = gcc
CFLAGS = Wall

all: proc-tree.o proc-common.o tree.o
	$(CC) -$(CFLAGS) proc-tree.o proc-common.o tree.o -o proc-tree

proc-common.o: proc-common.c
	$(CC) -$(CFLAGS) -c proc-common.c

proc-tree.o: proc-tree.c
	$(CC) -$(CFLAGS) -c proc-tree.c

tree.o: tree.c
	$(CC) -$(CFLAGS) -c tree.c

clean:
	rm proc-tree.o proc-common.o tree.o proc-tree