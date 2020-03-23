# strace
Ref: http://blog.livedoor.jp/sonots/archives/18193659.html

system callの統計情報を取得
```bash
# -c (--count option)
$ strace -fc ls
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
  0.00    0.000000           0         7           read
  0.00    0.000000           0         9           open
  0.00    0.000000           0        11           close
  0.00    0.000000           0         9           fstat
  0.00    0.000000           0        19           mmap
  0.00    0.000000           0        12           mprotect
  0.00    0.000000           0         1           munmap
  0.00    0.000000           0         3           brk
  0.00    0.000000           0         2           rt_sigaction
  0.00    0.000000           0         1           rt_sigprocmask
  0.00    0.000000           0         2           ioctl
  0.00    0.000000           0         7         7 access
  0.00    0.000000           0         1           execve
  0.00    0.000000           0         2           getdents
  0.00    0.000000           0         1           getrlimit
  0.00    0.000000           0         2         2 statfs
  0.00    0.000000           0         1           arch_prctl
  0.00    0.000000           0         1           set_tid_address
  0.00    0.000000           0         1           set_robust_list
------ ----------- ----------- --------- --------- ----------------
100.00    0.000000                    92         9 total
```

統計情報から重そうなsystem callを絞り込んでtrace
```bash
$ strace -Ttt -f -s1024 -e trace=open ls
19:50:13.745869 open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
19:50:13.746039 open("/lib/x86_64-linux-gnu/libselinux.so.1", O_RDONLY|O_CLOEXEC) = 3
19:50:13.746286 open("/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
19:50:13.746536 open("/lib/x86_64-linux-gnu/libpcre.so.3", O_RDONLY|O_CLOEXEC) = 3
19:50:13.746747 open("/lib/x86_64-linux-gnu/libdl.so.2", O_RDONLY|O_CLOEXEC) = 3
19:50:13.747003 open("/lib/x86_64-linux-gnu/libpthread.so.0", O_RDONLY|O_CLOEXEC) = 3
19:50:13.748364 open("/proc/filesystems", O_RDONLY) = 3
19:50:13.748570 open("/usr/lib/locale/locale-archive", O_RDONLY|O_CLOEXEC) = 3
19:50:13.748800 open(".", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = 3
19:50:13.749142 +++ exited with 0 +++
```

processにattachする場合
```bash
# -f (--fork option) がすべての process/thread を監視してくれる
$ strace -Ttt -f -s1024 -p<PID> -e trace=open
```

stdoutからpipeしたい場合
straceの出力はstderrに吐かれるのでredirectが必要
```bash
$ strace mysql 2>&1  | grep 'open' | grep '.cnf'
```
