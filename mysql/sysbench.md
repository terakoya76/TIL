# Sysbench

How to
- https://github.com/akopytov/sysbench

```bash
$ conn=" --db-driver=mysql --mysql-host=127.0.0.1 --mysql-user=root --mysql-password=root --mysql-db=sbtest "
$ sysbench $conn \
      oltp_read_write \
      prepare
$ sysbench $conn \
      oltp_read_write \
      run
$ sysbench $conn \
      oltp_read_write \
      cleanup
```

Typical Test Scenario

| Scenario        | Desc            |
|-----------------|-----------------|
| oltp_read_write | read/write OLTP |
| oltp_read_only  | read OLTP       |
| oltp_write_only | write OLTP      |

