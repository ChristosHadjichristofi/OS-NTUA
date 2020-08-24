#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>


void doWrite(int fd_dest,const char *buff)
{
	size_t len,idx;
	ssize_t wcnt;

	idx = 0;
	len = strlen(buff);
	do {
		wcnt = write(fd_dest, buff + idx, len - idx);
		if (wcnt == -1){
			perror("write");
			exit(1);
		}
		idx += wcnt;

	} while (idx < len);

}

void write_file(int fd,int fd_dest, const char *infile)
{	
	ssize_t rcnt;
	char buff[1024];

	for (;;)
	{
		rcnt = read(fd,buff,sizeof(buff)-1);

		if (rcnt == 0)
			break;
		if ((rcnt == -1)){
			perror("read");
			exit(1);
		}
		buff[rcnt] = '\0';
	}

	doWrite(fd_dest,buff);
}


int main( int argc, char **argv )
{

	if ((argc > 4)||(argc < 3)){
	    printf("Usage ./fconc infile1 infile2 [output (default:fconc.out)]\n");
	    return -1;
	}
	if (argc == 3) argv[3] = "fconc.out";
	
	if (strcmp(argv[1],argv[3]) == 0 || strcmp(argv[2],argv[3]) == 0){
	    printf("This action cannot be operated.\n");
	    printf("Destination file should differ from source files.\n");
	    return -1;
	} 
	
	char *firstfile = argv[1];
	char *secondfile = argv[2];
	char *destname = argv[3];
	int fd1,fd2,fd3;

	fd1 = open(firstfile, O_RDONLY);
	fd2 = open(secondfile, O_RDONLY);
	fd3 = open(destname, O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR);

	if((fd1 == -1)||(fd2 == -1)||(fd3 == -1)){
		perror("open");
		exit(1);
	}

	write_file(fd1,fd3,firstfile);
	write_file(fd2,fd3,secondfile);

	close(fd1);
	close(fd2);
	close(fd3);
	return 0;
}

