How to
- https://github.com/Percona-Lab/sysbench-tpcc

```bash
$ git clone https://github.com/Percona-Lab/sysbench-tpcc
$ cd sysbench-tpcc
$ conn=" --db-driver=mysql --mysql-host=127.0.0.1 --mysql-user=root --mysql-password=root --mysql-db=sbtest "
$ ./tpcc.lua $conn prepare
$ ./tpcc.lua $conn run
$ ./tpcc.lua $conn cleanup
```
