// Test pid namespace

#define _GNU_SOURCE
#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>

#define STACK_SIZE (1024 * 1024)
static char child_stack[STACK_SIZE];
char * const child_args[] = {
  "/bin/bash",
  NULL,
};

int child_main(void *arg)
{
	pid_t pid;
        printf("world\n");
	// set hostname in my namespace
        sethostname("in namespace", 12);

	// first porcess in new pid namespace,
	// getpid() should return 1
	printf("my pid %d\n", getpid());

	if ((pid = fork()) == 0) {
		execv(child_args[0], child_args);
		printf("oops\n");
	} else {
		// second process in pid namespace
		// pid should be 2
		printf("pid after fork %d\n", pid);
	}
	return 1;
}

int main(int argc, char **argv)
{
        int child_pid;
        printf("hello\n");
        child_pid = clone(child_main, child_stack + STACK_SIZE,
			  SIGCHLD | CLONE_NEWUTS | CLONE_NEWIPC | CLONE_NEWPID, NULL);
	printf("-- child pid %d\n", child_pid);
        waitpid(child_pid, NULL, 0);
        return 0;
}

  
