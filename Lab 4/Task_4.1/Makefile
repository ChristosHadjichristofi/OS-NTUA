#
# Makefile
#
# Operating Systems, Exercise 4
#

CC = gcc
#CFLAGS = -Wall -g
CFLAGS = -Wall -O2 -g

all: scheduler prog

scheduler: scheduler.o proc-common.o
	$(CC) -o scheduler scheduler.o proc-common.o
	
prog: prog.o proc-common.o
	$(CC) -o prog prog.o proc-common.o
	
proc-common.o: proc-common.c proc-common.h
	$(CC) $(CFLAGS) -o proc-common.o -c proc-common.c
	
scheduler.o: scheduler.c proc-common.h request.h
	$(CC) $(CFLAGS) -o scheduler.o -c scheduler.c
	
prog.o: prog.c
	$(CC) $(CFLAGS) -o prog.o -c prog.c
	
clean:
	rm -f scheduler prog *.o 

