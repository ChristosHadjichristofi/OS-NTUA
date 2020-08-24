#include <stdio.h>
#include <unistd.h>
#include "zing.h"

void zing(void)
{
	char *name;
	name = getlogin();
	printf("Goodbye, %s\n", name);
}

