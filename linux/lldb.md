## LLDB

### Install
```bash
$ apt install -y lldb
```

### Command Map to GDB
cf. https://lldb.llvm.org/use/map.html

### Debug Already Running Process
attach
```bash
# attach
$ lldb -p <pid>

# print backtrace
(lldb) bt

# step-in (step)
(lldb) s

# step-over (next)
(lldb) n

# stop interrupt
(lldb) c

# interrupt again
(lldb) process interrupt
```

examine variables
```bash
# show all local variables in the curr frame
(lldb) fr v -a

# show specific local variable in the curr frame
(lldb) fr v foo

# show all global/static variables
(lldb) ta v

# show specific global/static variable
(lldb) ta v foo
```

remote debug
```bash
(lldb) gdb-remote eorgadd:8000
```

### Debug Local Executable
execute
```bash
# exec a.out with args 1,2,3
$ lldb -- a.out 1 2 3

# run
(lldb) r
```

breakpoint
```bash
# breakpoint set
(lldb) br s <option>

# file: foo.c
# loc: 12
(lldb) br s -f foo.c -l 12

# function name: foo
(lldb) br s -n foo

# method name: foo
(lldb) br s -M foo

# show breakpoint list
(lldb) br list
```
