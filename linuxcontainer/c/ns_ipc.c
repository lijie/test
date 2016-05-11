// Test ipc namespace

#define _GNU_SOURCE
#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>
#include <fcntl.h>           /* For O_* constants */
#include <sys/stat.h>        /* For mode constants */
#include <mqueue.h>
#include <assert.h>
#include <errno.h>
#include <string.h>

#define STACK_SIZE (1024 * 1024)
static char child_stack[STACK_SIZE];
char * const child_args[] = {
  "/bin/bash",
  NULL,
};

int child_main(void *arg)
{
	mqd_t q;
	struct mq_attr attr;
	attr.mq_flags = 0;
	attr.mq_maxmsg = 10;
	attr.mq_msgsize = 16384;
	attr.mq_curmsgs = 0;

	// because child has a new ipc namespace,
	// the mq_open() without O_CREATE will fail.
	q = mq_open("/myqueue", O_RDWR, 0644, &attr);
	if (q < 0) {
		fprintf(stderr, "%s\n", strerror(errno));
	}
	assert(q < 0);
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
	mqd_t q;
	struct mq_attr attr;
        printf("hello\n");

	attr.mq_flags = 0;
	attr.mq_maxmsg = 10;
	attr.mq_msgsize = 16384;
	attr.mq_curmsgs = 0;
	
	q = mq_open("/myqueue", O_CREAT | O_RDWR, 0644, &attr);
	if (q < 0) {
		fprintf(stderr, "%s\n", strerror(errno));
		assert(q >= 0);
	}
	q = mq_open("/myqueue", O_RDWR, 0644, &attr);
	assert(q >= 0);

        child_pid = clone(child_main, child_stack + STACK_SIZE,
			  SIGCHLD | CLONE_NEWUTS | CLONE_NEWIPC, NULL);
        waitpid(child_pid, NULL, 0);
        return 0;
}

  
