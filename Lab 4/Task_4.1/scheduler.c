#include <errno.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <signal.h>
#include <string.h>
#include <assert.h>
#include <sys/wait.h>
#include <sys/types.h>
#include "proc-common.h"
#include "request.h"
/* Compile-time parameters. */
#define SCHED_TQ_SEC 2                /* time quantum */
#define TASK_NAME_SZ 60               /* maximum size for a task's name */

//creating a struct, every procedure is saved in a node 
//nodes are linked to create a custom queue structure
struct node{
	pid_t pid;
	int numproc;
	struct node *next;
};

//declare the head, tail and it nodes of the queue
struct node *head = NULL, *tail = NULL, *it = NULL;

//function used to delete an element from the queue based on its pid
void deleteNode(pid_t p){
	struct node *toBeDeleted=head;
	while (toBeDeleted->pid != p)
		toBeDeleted = toBeDeleted->next;
	if (toBeDeleted!=NULL && (toBeDeleted->next != toBeDeleted)){
		struct node *q = head;
		while (q->next!=toBeDeleted)
			q = q->next;
		if(toBeDeleted==head)
			head=head->next;
		if(toBeDeleted==tail)
			tail=q;
		q->next=toBeDeleted->next;
		free(toBeDeleted);
	}
	else {
		head = NULL;
		tail = NULL;
		free(toBeDeleted);
	}
}

//SIGALRM handler to stop a procedure
static void sigalrm_handler(int signum){
	kill(it->pid,SIGSTOP);
}

//SIGCHLD handler to start the next procedure
static void
sigchld_handler(int signum)
{
	pid_t p;
	int status;
	for(;;){
		p = waitpid(-1, &status, WUNTRACED | WNOHANG);
		if (p < 0){
			perror("waitpid");
			exit(1);
		}
		if (p == 0)
			break;
		explain_wait_status(p,status);
		if (WIFEXITED(status) || WIFSIGNALED(status) || WIFSTOPPED(status)){
			//if child was terminated normally or by signal then it must be removed from the queue
			if (WIFEXITED(status) || WIFSIGNALED(status)){
				deleteNode(p);
				if (head == NULL)
					exit(0);
			}
			//gives signal to the next procedure to start
			it = it->next;
			kill(it->pid,SIGCONT);
			alarm(SCHED_TQ_SEC);
		}
	}
}

/* Install two signal handlers.
 * One for SIGCHLD, one for SIGALRM.
 * Make sure both signals are masked when one of them is running.
 */
static void install_signal_handlers(void){
	sigset_t sigset;
	struct sigaction sa;
	sa.sa_handler = sigchld_handler;
	sa.sa_flags = SA_RESTART;
	sigemptyset(&sigset);
	sigaddset(&sigset, SIGCHLD);
	sigaddset(&sigset, SIGALRM);
	sa.sa_mask = sigset;
	if (sigaction(SIGCHLD, &sa, NULL) < 0) {
		perror("sigaction: sigchld");
		exit(1);
	}
	sa.sa_handler = sigalrm_handler;
	if (sigaction(SIGALRM, &sa, NULL) < 0) {
		perror("sigaction: sigalrm");
		exit(1);
	}
	/*
	 * Ignore SIGPIPE, so that write()s to pipes
	 * with no reader do not result in us being killed,
	 * and write() returns EPIPE instead.
	 */
	if (signal(SIGPIPE, SIG_IGN) < 0) {
		perror("signal: sigpipe");
		exit(1);
	}
}

int main(int argc, char *argv[])
{
	int nproc,i;
	/*
	 * For each of argv[1] to argv[argc - 1],
	 * create a new child process, add it to the process list.
	 */
	for(i=1;i<argc;i++){
		struct node *curr = (struct node*) malloc(sizeof(struct node));
		curr->pid = fork();
		if(curr->pid<0){
			perror("fork");
			exit(1);
		}
		if(curr->pid==0){
			char *executable = argv[i];
			char *newargv[] = { executable, NULL, NULL, NULL };
			char *newenviron[] = { NULL };
			printf("I am %s, PID = %ld\n", argv[0], (long)getpid());
			printf("About to replace myself with the executable %s...\n", executable);
			sleep(2);
			raise(SIGSTOP);
			execve(executable, newargv, newenviron);
			/* execve() only returns on error */
			perror("execve");
			exit(1);
		}
		curr->numproc = i-1;
		//if queue is empty then curr node is added as both head and tail
		if (head == NULL){
			head = curr;
			head->next = head;
			tail = head;
		}
		//else, curr node is added to the end of the queue
		else{
			tail->next = curr;
			curr->next = head;
			tail=curr;
		}
	}
	nproc = argc-1; /* number of proccesses goes here */
	/* Wait for all children to raise SIGSTOP before exec()ing. */
	wait_for_ready_children(nproc);
	/* Install SIGALRM and SIGCHLD handlers. */
	install_signal_handlers();
	//checks if there are any procedures
	if (nproc == 0) {
		fprintf(stderr, "Scheduler: No tasks. Exiting...\n");
		exit(1);
	}
	//it sends signal to the first procedure to start
	it = head;
	if(kill(head->pid, SIGCONT) < 0){
        perror("First child Cont error");
        exit(1);
    }
	alarm(SCHED_TQ_SEC);
	/* loop forever  until we exit from inside a signal handler. */
	while (pause())
		;
	/* Unreachable */
	fprintf(stderr, "Internal error: Reached unreachable point\n");
	return 1;
}