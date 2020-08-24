#
# Makefile
#
# Operating Systems, Exercise 4
#

CC = gcc
#CFLAGS = -Wall -g
CFLAGS = -Wall -O2 -g

all: scheduler-priority shell prog

scheduler-priority: scheduler-priority.o proc-common.o
	$(CC) -o scheduler-priority scheduler-priority.o proc-common.o
	
shell: shell.o proc-common.o
	$(CC) -o shell shell.o proc-common.o
	
prog: prog.o proc-common.o
	$(CC) -o prog prog.o proc-common.o
	
scheduler-priority.o: scheduler-priority.c proc-common.h request.h
	$(CC) $(CFLAGS) -o scheduler-priority.o -c scheduler-priority.c	

shell.o: shell.c proc-common.h request.h
	$(CC) $(CFLAGS) -o shell.o -c shell.c
	
proc-common.o: proc-common.c proc-common.h
	$(CC) $(CFLAGS) -o proc-common.o -c proc-common.c
	
prog.o: prog.c
	$(CC) $(CFLAGS) -o prog.o -c prog.c
	
clean:
	rm -f scheduler-priority shell prog *.o 

