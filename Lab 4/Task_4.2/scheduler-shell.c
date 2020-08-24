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
#define SHELL_EXECUTABLE_NAME "shell" /* executable for shell */

//creating a struct, every procedure is saved in a node 
//nodes are linked to create a custom queue structure
//exec attribute was added to the struct to keep the name of the procedure
//and determine the shell procedure
struct node{
	pid_t pid;
	int numproc;
	char exec[TASK_NAME_SZ];
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

/* Print a list of all tasks currently being scheduled.  */
static void sched_print_tasks(void){
	struct node *temp=head;
	printf("all procedures: ");
	do{
		printf("(%d, %d, %s)",temp->numproc,temp->pid,temp->exec);
		temp=temp->next;
	}while(temp!=head);
	printf("\nActive procedure: (%d, %d, %s)\n",it->numproc,it->pid,it->exec);
}

/* Send SIGKILL to a task determined by the value of its
 * scheduler-specific id.
 */
static int sched_kill_task_by_id(int id){
	struct node *temp=head;
	while(temp->numproc!=id){
		temp=temp->next;
		/*if there is no process with an id that matches the one given as a parameter
		  then temp will reach the head of the queue in that case it returns the signal ESRCH
		  ESRCH: “No such process.” No process matches the specified process ID
		*/
		if(temp==head)
			return -ESRCH;
	}
	return kill(temp->pid,SIGKILL);
}

// Create a new task using the given executable name and adding it to tail of the queue
static void sched_create_task(char *executable){
	struct node *curr = (struct node*) malloc(sizeof(struct node));
	curr->pid = fork();
	if(curr->pid<0){
		perror("fork");
		exit(1);
	}
	if(curr->pid==0){
		char *newargv[] = { executable, NULL, NULL, NULL };
		char *newenviron[] = { NULL };
		printf("I am a new process %s...\n", executable);
		raise(SIGSTOP);
		execve(executable, newargv, newenviron);
		/* execve() only returns on error */
		perror("execve");
		exit(1);
	}
	curr->numproc = (tail->numproc)+1;
	strcpy(curr->exec ,executable);
	tail->next = curr;
	curr->next = head;
	tail=curr;
	wait_for_ready_children(1);
}

/* Process requests by the shell.  */
static int process_request(struct request_struct *rq){
	switch (rq->request_no) {
		case REQ_PRINT_TASKS:
			sched_print_tasks();
			return 0;

		case REQ_KILL_TASK:
			return sched_kill_task_by_id(rq->task_arg);

		case REQ_EXEC_TASK:
			sched_create_task(rq->exec_task_arg);
			return 0;

		default:
			return -ENOSYS;
	}
}

//SIGALRM handler to stop a procedure
static void sigalrm_handler(int signum){
	kill(it->pid,SIGSTOP);
}

//SIGCHLD handler to start the next procedure
static void sigchld_handler(int signum){
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

/* Disable delivery of SIGALRM and SIGCHLD. */
static void signals_disable(void){
	sigset_t sigset;
	sigemptyset(&sigset);
	sigaddset(&sigset, SIGALRM);
	sigaddset(&sigset, SIGCHLD);
	if (sigprocmask(SIG_BLOCK, &sigset, NULL) < 0) {
		perror("signals_disable: sigprocmask");
		exit(1);
	}
}

/* Enable delivery of SIGALRM and SIGCHLD.  */
static void signals_enable(void){
	sigset_t sigset;
	sigemptyset(&sigset);
	sigaddset(&sigset, SIGALRM);
	sigaddset(&sigset, SIGCHLD);
	if (sigprocmask(SIG_UNBLOCK, &sigset, NULL) < 0) {
		perror("signals_enable: sigprocmask");
		exit(1);
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

static void do_shell(char *executable, int wfd, int rfd){
	char arg1[10], arg2[10];
	char *newargv[] = { executable, NULL, NULL, NULL };
	char *newenviron[] = { NULL };
	sprintf(arg1, "%05d", wfd);
	sprintf(arg2, "%05d", rfd);
	newargv[1] = arg1;
	newargv[2] = arg2;
	raise(SIGSTOP);
	execve(executable, newargv, newenviron);
	/* execve() only returns on error */
	perror("scheduler: child: execve");
	exit(1);
}

/* Create a new shell task.
 * The shell gets special treatment:
 * two pipes are created for communication and passed
 * as command-line arguments to the executable.
 */
static void sched_create_shell(char *executable, int *request_fd, int *return_fd){
	pid_t p;
	int pfds_rq[2], pfds_ret[2];
	if (pipe(pfds_rq) < 0 || pipe(pfds_ret) < 0) {
		perror("pipe");
		exit(1);
	}
	p = fork();
	if (p < 0) {
		perror("scheduler: fork");
		exit(1);
	}
	if (p == 0) {
		/* Child */
		close(pfds_rq[0]);
		close(pfds_ret[1]);
		do_shell(executable, pfds_rq[1], pfds_ret[0]);
		assert(0);
	}
	/* Parent */
	head->pid = p;   	//shell's pid is saved in the structure
	close(pfds_rq[1]);
	close(pfds_ret[0]);
	*request_fd = pfds_rq[0];
	*return_fd = pfds_ret[1];
}

static void shell_request_loop(int request_fd, int return_fd){
	int ret;
	struct request_struct rq;
	/*
	 * Keep receiving requests from the shell.
	 */
	for (;;) {
		if (read(request_fd, &rq, sizeof(rq)) != sizeof(rq)) {
			perror("scheduler: read from shell");
			fprintf(stderr, "Scheduler: giving up on shell request processing.\n");
			break;
		}
		signals_disable();
		ret = process_request(&rq);
		signals_enable();
		if (write(return_fd, &ret, sizeof(ret)) != sizeof(ret)) {
			perror("scheduler: write to shell");
			fprintf(stderr, "Scheduler: giving up on shell request processing.\n");
			break;
		}
	}
}

int main(int argc, char *argv[]){
	int nproc,i;
	/* Two file descriptors for communication with the shell */
	static int request_fd, return_fd;
	head = (struct node*) malloc(sizeof(struct node));
	/* Create the shell. */
	sched_create_shell(SHELL_EXECUTABLE_NAME, &request_fd, &return_fd);
	//create a node for the shell and place it as the head of the queue
	strcpy(head->exec , SHELL_EXECUTABLE_NAME);
	head->numproc=0;
	head->next=head;
	tail=head;
	nproc = argc-1; /* number of proccesses goes here */
	/*
	 * For each of argv[1] to argv[argc - 1],
	 * create a new child process, add it to the process list.
	 */	
	for(i=1;i<=nproc;i++){
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
		curr->numproc = i;
		strcpy(curr->exec ,argv[i]);
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
	/* Wait for all children to raise SIGSTOP before exec()ing. */
	wait_for_ready_children(nproc+1);
	/* Install SIGALRM and SIGCHLD handlers. */
	install_signal_handlers();
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
	shell_request_loop(request_fd, return_fd);
	/* Now that the shell is gone, just loop forever
	 * until we exit from inside a signal handler.
	 */
	while (pause())
		;
	/* Unreachable */
	fprintf(stderr, "Internal error: Reached unreachable point\n");
	return 1;
}

