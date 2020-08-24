#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>
#include "tree.h"
#include "proc-common.h"
#include <stdbool.h>
#define SLEEP 2


void fork_procs(struct tree_node *root, int fd) {
	//Start 
	printf("PID = %ld, name %s, starting...\n", (long)getpid(), root->name);
	change_pname(root->name);

	if(root->nr_children == 0){
		int answer = atoi(root -> name);
		if (write(fd, &answer , sizeof(answer)) != sizeof(answer)){ 
			perror("read from pipe");
			exit(1);
		}
		close(fd);
		sleep(SLEEP);
		exit(0);
	}

	int status,fdLeft[2],fdRight[2],valueLeft,valueRight,answer;
	pid_t pid,pidRight,pidLeft;

	/*RIGHT CHILD*/
	if(pipe(fdRight) < 0){
		perror("pipe");
		exit(1);
	}
	pidRight = fork();
	if(pidRight == 0){
		close(fdRight[0]);
		fork_procs(root->children,fdRight[1]);
	}
	close(fdRight[1]);

	/*LEFT CHILD*/
	if(pipe(fdLeft) < 0){
		perror("pipe");
		exit(1);
	}
	pidLeft = fork();
	if(pidLeft == 0){
		close(fdLeft[0]);
		fork_procs(root->children+1,fdLeft[1]);
	}
	close(fdLeft[1]);

	/*FATHER*/
	/*getting the values from each pipe(Left and Right)*/
	if (read(fdRight[0], &valueRight, sizeof(valueRight)) != sizeof(valueRight)){
		perror("read from pipe");
		exit(1);
	}
	close(fdRight[0]);

	printf("%s received value: value = %d\n",root->name, valueRight);
	pid = wait(&status);
	explain_wait_status(pid, status);

	if (read(fdLeft[0], &valueLeft, sizeof(valueLeft)) != sizeof(valueLeft)){
		perror("read from pipe");
		exit(1);
	}
	close(fdLeft[0]);
	printf("%s received value: value = %d\n",root->name, valueLeft);
	pid = wait(&status);
	explain_wait_status(pid, status);

	/*Computation*/
	switch(strcmp(root->name,"*")) {
	case 0:
		printf("I am PID = %ld am multi %d and %d\n", (long)getpid(),valueLeft, valueRight);
		answer = valueLeft * valueRight;
		printf("Answer is %d\n",answer);
		break;
	default:
		printf("I am PID = %ld am adding %d and %d\n",(long)getpid(),valueLeft, valueRight);
		answer = valueLeft + valueRight;
		printf("Answer is %d\n",answer);
	}
	if (write(fd, &answer, sizeof(answer)) != sizeof(answer)) {
		perror("pipe");
		exit(1);
	}
	close(fd);
	exit(0);
}

int main(int argc, char *argv[])
{
	pid_t pid;
	int status,fd[2],finalAns;
	struct tree_node *root;

	if (argc < 2){
		fprintf(stderr, "Usage: %s <tree_file>\n", argv[0]);
		exit(1);
	}

	/* Read tree into memory */
	root = get_tree_from_file(argv[1]);
	
	
	if(pipe(fd)<0){
		perror("main: pipe");
		exit(1);
	}
		

	/* Fork root of process tree */
	pid = fork();
	if (pid < 0) {
		perror("main: fork");
		exit(1);
	}
	if (pid == 0) {
		/* Child */
		fork_procs(root,fd[1]);
		exit(1);
	}
	//close(fd[1]);
	/* Print the process tree root at pid */
	show_pstree(pid);

	if(read(fd[0], &finalAns, sizeof(finalAns)) != sizeof(finalAns)){
		perror("read from pipe");
		exit(1);
	}

	//close(fd[0]);
	printf("This is the final result: %d \n",finalAns);

	/* Wait for the root of the process tree to terminate */
	wait(&status);
	explain_wait_status(pid, status);

	return 0;
}
