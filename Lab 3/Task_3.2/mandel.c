/*
 * mandel.c
 *
 * A program to draw the Mandelbrot Set on a 256-color xterm using multiple threads.
 *
 */

#include <stdio.h>
#include <unistd.h>
#include <assert.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include <errno.h>
#include <pthread.h>
#include <semaphore.h>
#include "mandel-lib.h"
#define MANDEL_MAX_ITERATION 100000
#define perror_pthread(ret, msg) \
	do { errno = ret; perror(msg); } while (0)

/***************************
 * Compile-time parameters *
 ***************************/

//creating a semaphore and delcaring variable for the number of threads
sem_t *semaphore;
int NTHREADS;

//Output at the terminal is is x_chars wide by y_chars long
int y_chars = 50;
int x_chars = 90;

/*
 * The part of the complex plane to be drawn:
 * upper left corner is (xmin, ymax), lower right corner is (xmax, ymin)
*/
double xmin = -1.8, xmax = 1.0;
double ymin = -1.0, ymax = 1.0;
/*
 * Every character in the final output is
 * xstep x ystep units wide on the complex plane.
 */
double xstep;
double ystep;

//A (distinct) instance of this structure is passed to each thread
struct thread_info_struct {
	pthread_t tid; /* POSIX thread id, as returned by the library */
	int thrid; /* Application-defined thread id */
};

//ensures that input is valid and converts it to integer
int safe_atoi(char *s, int *val)
{
	long l;
	char *endp;

	l = strtol(s, &endp, 10);
	if (s != endp && *endp == '\0') {
		*val = l;
		return 0;
	} else
		return -1;
}

//ensures that there is enough space and allocates memory
void *safe_malloc(size_t size)
{
	void *p;

	if ((p = malloc(size)) == NULL) {
		fprintf(stderr, "Out of memory, failed to allocate %zd bytes\n",
			size);
		exit(1);
	}

	return p;
}

/*
 * This function computes a line of output
 * as an array of x_char color values.
 */
void compute_mandel_line(int line, int color_val[])
{
	/*
	 * x and y traverse the complex plane.
	 */
	double x, y;

	int n;
	int val;

	/* Find out the y value corresponding to this line */
	y = ymax - ystep * line;

	/* and iterate for all points on this line */
	for (x = xmin, n = 0; n < x_chars; x+= xstep, n++) {

		/* Compute the point's color value */
		val = mandel_iterations_at_point(x, y, MANDEL_MAX_ITERATION);
		if (val > 255)
			val = 255;

		/* And store it in the color_val[] array */
		val = xterm_color(val);
		color_val[n] = val;
	}
}

/*
 * This function outputs an array of x_char color values
 * to a 256-color xterm.
 */
void output_mandel_line(int fd, int color_val[])
{
	int i;
	
	char point ='@';
	char newline='\n';

	for (i = 0; i < x_chars; i++) {
		/* Set the current color, then output the point */
		set_xterm_color(fd, color_val[i]);
		if (write(fd, &point, 1) != 1) {
			perror("compute_and_output_mandel_line: write point");
			exit(1);
		}
	}

	/* Now that the line is done, output a newline character */
	if (write(fd, &newline, 1) != 1) {
		perror("compute_and_output_mandel_line: write newline");
		exit(1);
	}
}

void *compute_and_output_mandel_line(void *arg)
{ 
	//A temporary array, used to hold color values for the line being drawn
	int color_val[x_chars];
	//indicates the lines that are creted by the current thread
	int j;
	//makes a copy of the argument arg 
	struct thread_info_struct *th = arg;
	//current contains the id of the current thread
	int current = th->thrid;
	//next contains the id of the thread that comes after the current
	int next = (current + 1 ) % NTHREADS;

	/* 	ith thread computes the ith and all the k*NTHREADS+ith lines 
		where K=1,2,3,... and k*NTHREADS+i < y_chars
		output_mandel_line is the critical section of the code
		and must be executed by one thread at a time.
		In each iteration the program computes the values for the line,
		then ensures that only the current thread is active 
		and enters the critical section, prints the line 
		and exits the critical section
	*/
	for(j = th->thrid; j < y_chars; j += NTHREADS){
		compute_mandel_line(j, color_val);
		sem_wait(&semaphore[current]);
		output_mandel_line(1, color_val);
		//reset_xterm_color(1);     
		sem_post(&semaphore[next]);
	}
	return NULL;
}

int main(int argc, char *argv[])
{
	int ret,i;
	struct thread_info_struct *thr;
	
	//checking input, if given number of threads is  valid, it is saved in the variable NTHREADS
	if(argc == 2){
		safe_atoi(argv[1], &NTHREADS);
		if(NTHREADS>y_chars){
			printf("Usage error: Number of threads cannot be larger than y_chars\n");
			exit(1);
		}			
	}
	else{
		printf("Usage error: Exactly 1 argument required\n");
		exit(1);
	}
		
	xstep = (xmax - xmin) / x_chars;
	ystep = (ymax - ymin) / y_chars;

	//checks if there is enough space to allocate for threads and semaphores via safe_malloc
	thr = safe_malloc(NTHREADS*sizeof(sem_t));
	semaphore = safe_malloc(NTHREADS*sizeof(sem_t));

    //initialize semaphores, 1st semaphores is unlocked and set to 1 
	//and all the others are locked and set to 0
    for(i=1; i<NTHREADS; i++){
        sem_init(&semaphore[i], 0, 0);
    }
	sem_init(&semaphore[0], 0, 1);

	//creates NTHREADS threads
	for (i = 0; i < NTHREADS; i++) {
		/* Initialize per-thread structure */
		thr[i].thrid = i;
		/* Spawn new thread */
		ret = pthread_create(&thr[i].tid, NULL, compute_and_output_mandel_line, &thr[i]);
		if (ret) {
			perror_pthread(ret, "pthread_create");
			exit(1);
		}
	} 
	 
	// Wait for all threads to terminate
	for (i = 0; i < NTHREADS; i++) {
		ret = pthread_join(thr[i].tid, NULL);
		if (ret) {
			perror_pthread(ret, "pthread_join");
			exit(1);
		}
	} 
	
	reset_xterm_color(1);
	return 0;
}
