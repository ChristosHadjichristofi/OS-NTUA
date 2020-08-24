#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/wait.h>

#include "proc-common.h"

#define SLEEP_PROC_SEC  10
#define SLEEP_TREE_SEC  3

/*
 * Create this process tree:
 * A-+-B---D
 *   `-C
 */
void fork_procs(void)
{	
	int status;
	pid_t B,C,D;
	/* initial process is A. */
	change_pname("A");
	printf("A creates B...\n");
	B = fork();

	if(B < 0){
			perror("Error B\n");
			exit(1);
	} 
	else if(B == 0){
		change_pname("B");

		printf("B creates D...\n");
		D = fork();
		if( D < 0 ){
			perror("Error D\n");
			exit(1);
		}
		else if( D == 0){
			change_pname("D");
			printf("D: Sleeping...\n");
			sleep(SLEEP_PROC_SEC);
			printf("D: Exiting...\n");
			exit(13);
		}
		else{
			D = wait(&status);
			explain_wait_status(D,status);
			printf("B: Exiting...\n");
			exit(19);
		}
	}
	else{
		printf("A creates C...\n");
		C = fork();
		if( C < 0){
			perror("Error C\n");
			exit(1);
		} 
		else if ( C == 0){
			change_pname("C");
			printf("C: Sleeping...\n");
			sleep(SLEEP_PROC_SEC);
			printf("C: Exiting...\n");
			exit(17);
		}
		else{
			C = wait(&status);
			explain_wait_status(C,status);
			B = wait(&status);
			explain_wait_status(B,status);
			sleep(SLEEP_PROC_SEC);
			printf("A: Exiting...\n");
			exit(16);
		}
	}
}

/*
 * The initial process forks the root of the process tree,
 * waits for the process tree to be completely created,
 * then takes a photo of it using show_pstree().
 *
 * How to wait for the process tree to be ready?
 * In ask2-{fork, tree}:
 *      wait for a few seconds, hope for the best.
 * In ask2-signals:
 *      use wait_for_ready_children() to wait until
 *      the first process raises SIGSTOP.
 */
int main(void)
{
	pid_t pid;
	int status;

	/* Fork root of process tree */
	pid = fork();
	if (pid < 0) {
		perror("main: fork");
		exit(1);
	}
	if (pid == 0) {
		/* Child */
		fork_procs();
		exit(1);
	}

	/* Father*/
	/* for ask2-signals */
	/* wait_for_ready_children(1); */

	/* for ask2-{fork, tree} */
	sleep(SLEEP_TREE_SEC);
	/* Print the process tree root at pid */
	show_pstree(pid);

	/* for ask2-signals */
	/* kill(pid, SIGCONT); */

	/* Wait for the root of the process tree to terminate */
	pid = wait(&status);
	explain_wait_status(pid, status);

	return 0;
}
