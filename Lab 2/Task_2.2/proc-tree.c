#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/wait.h>

#include "proc-common.h"
#include "tree.h"
#define SLEEP_PROC_SEC  10
#define SLEEP_TREE_SEC  3

void forking(struct tree_node *node){
	int i = 0, status;
	pid_t pid;
	change_pname(node -> name);

	while( i < node -> nr_children){
		if(fork() == 0)
			forking(node -> children + i);
		printf("I am %s, I forked %s and I must still fork %d children\n",node->name,(node->children+i)->name,node->nr_children-i-1);
		i++;
	}
	printf("I am %s and I will sleep now...\n",(node -> name));
	sleep(SLEEP_PROC_SEC);
	for ( i = 0; i < node -> nr_children; i++){
		pid = wait(&status);
		explain_wait_status(pid,status);
	}
	printf("I am %s, I woke up and im exiting...\n", (node -> name));
	exit(0);
}

int main(int argc, char *argv[]){

	struct tree_node *root;
	pid_t pid;
	int status;

	if (argc != 2) {
		fprintf(stderr, "Usage: %s <input_tree_file>\n\n", argv[0]);
		exit(1);
	}

	root = get_tree_from_file(argv[1]);
	pid = fork();
	if(pid < 0){
		perror("main: fork");
		exit(1);
	}
	if (pid == 0) {
		/* Child */
		forking(root);
		exit(1);
	}

	sleep(SLEEP_TREE_SEC);
	show_pstree(pid);

	pid = wait(&status);
	explain_wait_status(pid, status);

	return 0;
}