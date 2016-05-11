package main

import (
	"fmt"
	"syscall"
	"unsafe"
)

func main() {
	r1, _, err := syscall.RawSyscall6(syscall.SYS_CLONE,
		uintptr(syscall.CLONE_NEWUTS)|uintptr(syscall.SIGCHLD), 0, 0, 0, 0, 0)
	if err != 0 {
		fmt.Println(err)
		return
	}
	fmt.Printf("ok %d\n", int(r1))
	if int(r1) == 0 {
		syscall.Wait4(int(r1), nil, 0, nil)
		return
	}
	syscall.Sethostname([]byte("NewHostname"))

	var argv = []string{
		"/bin/bash",
	}

	if argvp, err := syscall.SlicePtrFromStrings(argv); err == nil {
		_, _, err = syscall.RawSyscall(syscall.SYS_EXECVE,
			uintptr(unsafe.Pointer(argvp[0])),
			uintptr(unsafe.Pointer(&argvp[0])),
			0)
	}
}
