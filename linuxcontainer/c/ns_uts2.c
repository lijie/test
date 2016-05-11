// Test UTS namespace

#define _GNU_SOURCE
#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>
#include <sys/syscall.h>   /* For SYS_xxx definitions */

#define STACK_SIZE (1024 * 1024)
static char child_stack[STACK_SIZE];
char * const child_args[] = {
  "/bin/bash",
  NULL,
};

int child_main(void *arg)
{
        printf("world\n");
	// set hostname in my namespace
        sethostname("in namespace", 12);
        execv(child_args[0], child_args);
        printf("oops\n");
        return 1;
}

int main(int argc, char **argv)
{
        int child_pid;
        printf("hello\n");
        child_pid = syscall(__NR_clone, SIGCHLD | CLONE_NEWUTS, NULL, 0, NULL, NULL, 0);
	if (child_pid != 0) {
		waitpid(child_pid, NULL, 0);
		return 0;
	}

	child_main(NULL);
        return 0;
}

  
