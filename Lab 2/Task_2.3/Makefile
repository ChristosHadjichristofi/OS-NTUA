CC = gcc
CFLAGS = Wall

all: ask2-signals.o proc-common.o tree.o
	$(CC) -$(CFLAGS) ask2-signals.o proc-common.o tree.o -o ask2-signals

proc-common.o: proc-common.c
	$(CC) -$(CFLAGS) -c proc-common.c

ask2-signals.o: ask2-signals.c
	$(CC) -$(CFLAGS) -c ask2-signals.c

tree.o: tree.c
	$(CC) -$(CFLAGS) -c tree.c

clean:
	rm ask2-signals.o proc-common.o tree.o ask2-signals