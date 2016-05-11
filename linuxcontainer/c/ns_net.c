// Test net namespace

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>

#define STACK_SIZE (1024 * 1024)
static char child_stack[STACK_SIZE];
char * const child_args[] = {
  "/bin/bash",
  NULL,
};

int checkpoint[2];

int child_main(void *arg)
{
	char c;
	close(checkpoint[1]);
        printf("world\n");
	// set hostname in my namespace
        sethostname("in namespace", 12);
	mount("proc", "/proc", "proc", 0, NULL);

	// wait parent
	read(checkpoint[0], &c, 1);

	system("ip link set lo up");
	system("ip link set veth1 up");
	system("ip addr add 192.168.1.101/24 dev veth1");
	system("route add default gw 192.168.1.100");

        execv(child_args[0], child_args);
        printf("oops\n");
        return 1;
}

int main(int argc, char **argv)
{
        int child_pid;
        printf("hello\n");
	pipe(checkpoint);
        child_pid = clone(child_main, child_stack + STACK_SIZE,
			  SIGCHLD | CLONE_NEWUTS | CLONE_NEWIPC | CLONE_NEWPID | CLONE_NEWNS | CLONE_NEWNET, NULL);

	char *cmd;
	asprintf(&cmd, "ip link set veth1 netns %d", child_pid);
	system("ip link add veth0 type veth peer name veth1");
	system(cmd);
	system("ip link set veth0 up");
	system("ip addr add 192.168.1.100/24 dev veth0");
	// system("iptables -t nat -F POSTROUTING");
	// system("iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eth1 -j MASQUERADE");
	free(cmd);

	close(checkpoint[1]);
        waitpid(child_pid, NULL, 0);
        return 0;
}

  
