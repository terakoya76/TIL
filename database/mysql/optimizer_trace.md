# Optimizer Trace

## SHOW STATUS VARIABLES LIKE 'HANDLER_%'
https://fromdual.com/mysql-handler-read-status-variables

```sql
-- session status を flush
mysql> FLUSH STATUS;

mysql> SELECT * FROM users;

mysql> SHOW STATUS VARIABLES LIKE 'HANDLER_%';
```

## Optimizer Trace
有効化
```sql
mysql> show variables like 'optimizer_trace';
+-----------------+--------------------------+
| Variable_name   | Value                    |
+-----------------+--------------------------+
| optimizer_trace | enabled=off,one_line=off |
+-----------------+--------------------------+
1 row in set (0.00 sec)

mysql> SET optimizer_trace="enabled=on";
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like 'optimizer_trace';
+-----------------+-------------------------+
| Variable_name   | Value                   |
+-----------------+-------------------------+
| optimizer_trace | enabled=on,one_line=off |
+-----------------+-------------------------+
1 row in set (0.00 sec)

-- memory 利用量増やす
mysql> show variables like 'optimizer_trace_max_mem_size';
+------------------------------+-------+
| Variable_name                | Value |
+------------------------------+-------+
| optimizer_trace_max_mem_size | 16384 |
+------------------------------+-------+
1 row in set (0.00 sec)

mysql> SET optimizer_trace_max_mem_size = 1048576;
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like 'optimizer_trace_max_mem_size';
+------------------------------+---------+
| Variable_name                | Value   |
+------------------------------+---------+
| optimizer_trace_max_mem_size | 1048576 |
+------------------------------+---------+
1 row in set (0.00 sec)
```

トレース
```sql
mysql> explain SELECT * FROM users;

mysql> SELECT * FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE\G
```
