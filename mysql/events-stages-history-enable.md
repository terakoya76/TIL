## Enable EventsStagesHistory
Ref: https://dev.mysql.com/doc/refman/5.7/en/performance-schema-stage-tables.html

### Initial State
```sql
mysql> SELECT * FROM performance_schema.setup_consumers WHERE NAME LIKE 'events_stages%';
+----------------------------+---------+
| NAME                       | ENABLED |
+----------------------------+---------+
| events_stages_current      | NO      |
| events_stages_history      | NO      |
| events_stages_history_long | NO      |
+----------------------------+---------+
3 rows in set (0.00 sec)

mysql> select * from  performance_schema.setup_instruments WHERE NAME like 'stage/%';
+----------------------------------------------------------------------------+---------+-------+
| NAME                                                                       | ENABLED | TIMED |
+----------------------------------------------------------------------------+---------+-------+
| stage/sql/After create                                                     | NO      | NO    |
| stage/sql/allocating local table                                           | NO      | NO    |
| stage/sql/preparing for alter table                                        | NO      | NO    |
| stage/sql/altering table                                                   | NO      | NO    |
| stage/sql/committing alter table to storage engine                         | NO      | NO    |
| stage/sql/Changing master                                                  | NO      | NO    |
| stage/sql/Checking master version                                          | NO      | NO    |
| stage/sql/checking permissions                                             | NO      | NO    |
| stage/sql/checking privileges on cached query                              | NO      | NO    |
| stage/sql/checking query cache for query                                   | NO      | NO    |
| stage/sql/cleaning up                                                      | NO      | NO    |
| stage/sql/closing tables                                                   | NO      | NO    |
| stage/sql/Compressing gtid_executed table                                  | NO      | NO    |
| stage/sql/Connecting to master                                             | NO      | NO    |
| stage/sql/converting HEAP to ondisk                                        | NO      | NO    |
| stage/sql/Copying to group table                                           | NO      | NO    |
| stage/sql/Copying to tmp table                                             | NO      | NO    |
| stage/sql/copy to tmp table                                                | YES     | YES   |
| stage/sql/Creating sort index                                              | NO      | NO    |
| stage/sql/creating table                                                   | NO      | NO    |
| stage/sql/Creating tmp table                                               | NO      | NO    |
| stage/sql/deleting from main table                                         | NO      | NO    |
| stage/sql/deleting from reference tables                                   | NO      | NO    |
| stage/sql/discard_or_import_tablespace                                     | NO      | NO    |
| stage/sql/end                                                              | NO      | NO    |
| stage/sql/executing                                                        | NO      | NO    |
| stage/sql/Execution of init_command                                        | NO      | NO    |
| stage/sql/explaining                                                       | NO      | NO    |
| stage/sql/Finished reading one binlog; switching to next binlog            | NO      | NO    |
| stage/sql/Flushing relay log and master info repository.                   | NO      | NO    |
| stage/sql/Flushing relay-log info file.                                    | NO      | NO    |
| stage/sql/freeing items                                                    | NO      | NO    |
| stage/sql/FULLTEXT initialization                                          | NO      | NO    |
| stage/sql/got handler lock                                                 | NO      | NO    |
| stage/sql/got old table                                                    | NO      | NO    |
| stage/sql/init                                                             | NO      | NO    |
| stage/sql/insert                                                           | NO      | NO    |
| stage/sql/invalidating query cache entries (table)                         | NO      | NO    |
| stage/sql/invalidating query cache entries (table list)                    | NO      | NO    |
| stage/sql/Killing slave                                                    | NO      | NO    |
| stage/sql/logging slow query                                               | NO      | NO    |
| stage/sql/Making temporary file (append) before replaying LOAD DATA INFILE | NO      | NO    |
| stage/sql/Making temporary file (create) before replaying LOAD DATA INFILE | NO      | NO    |
| stage/sql/manage keys                                                      | NO      | NO    |
| stage/sql/Master has sent all binlog to slave; waiting for more updates    | NO      | NO    |
| stage/sql/Opening tables                                                   | NO      | NO    |
| stage/sql/optimizing                                                       | NO      | NO    |
| stage/sql/preparing                                                        | NO      | NO    |
| stage/sql/Purging old relay logs                                           | NO      | NO    |
| stage/sql/query end                                                        | NO      | NO    |
| stage/sql/Queueing master event to the relay log                           | NO      | NO    |
| stage/sql/Reading event from the relay log                                 | NO      | NO    |
| stage/sql/Registering slave on master                                      | NO      | NO    |
| stage/sql/Removing duplicates                                              | NO      | NO    |
| stage/sql/removing tmp table                                               | NO      | NO    |
| stage/sql/rename                                                           | NO      | NO    |
| stage/sql/rename result table                                              | NO      | NO    |
| stage/sql/Requesting binlog dump                                           | NO      | NO    |
| stage/sql/reschedule                                                       | NO      | NO    |
| stage/sql/Searching rows for update                                        | NO      | NO    |
| stage/sql/Sending binlog event to slave                                    | NO      | NO    |
| stage/sql/sending cached result to client                                  | NO      | NO    |
| stage/sql/Sending data                                                     | NO      | NO    |
| stage/sql/setup                                                            | NO      | NO    |
| stage/sql/Slave has read all relay log; waiting for more updates           | NO      | NO    |
| stage/sql/Waiting for an event from Coordinator                            | NO      | NO    |
| stage/sql/Waiting for slave workers to process their queues                | NO      | NO    |
| stage/sql/Waiting for Slave Worker queue                                   | NO      | NO    |
| stage/sql/Waiting for Slave Workers to free pending events                 | NO      | NO    |
| stage/sql/Waiting for Slave Worker to release partition                    | NO      | NO    |
| stage/sql/Waiting for workers to exit                                      | NO      | NO    |
| stage/sql/Sorting for group                                                | NO      | NO    |
| stage/sql/Sorting for order                                                | NO      | NO    |
| stage/sql/Sorting result                                                   | NO      | NO    |
| stage/sql/Waiting until MASTER_DELAY seconds after master executed event   | NO      | NO    |
| stage/sql/statistics                                                       | NO      | NO    |
| stage/sql/storing result in query cache                                    | NO      | NO    |
| stage/sql/storing row into queue                                           | NO      | NO    |
| stage/sql/System lock                                                      | NO      | NO    |
| stage/sql/update                                                           | NO      | NO    |
| stage/sql/updating                                                         | NO      | NO    |
| stage/sql/updating main table                                              | NO      | NO    |
| stage/sql/updating reference tables                                        | NO      | NO    |
| stage/sql/upgrading lock                                                   | NO      | NO    |
| stage/sql/User sleep                                                       | NO      | NO    |
| stage/sql/verifying table                                                  | NO      | NO    |
| stage/sql/Waiting for GTID to be committed                                 | NO      | NO    |
| stage/sql/waiting for handler insert                                       | NO      | NO    |
| stage/sql/waiting for handler lock                                         | NO      | NO    |
| stage/sql/waiting for handler open                                         | NO      | NO    |
| stage/sql/Waiting for INSERT                                               | NO      | NO    |
| stage/sql/Waiting for master to send event                                 | NO      | NO    |
| stage/sql/Waiting for master update                                        | NO      | NO    |
| stage/sql/Waiting for the slave SQL thread to free enough relay log space  | NO      | NO    |
| stage/sql/Waiting for slave mutex on exit                                  | NO      | NO    |
| stage/sql/Waiting for slave thread to start                                | NO      | NO    |
| stage/sql/Waiting for table flush                                          | NO      | NO    |
| stage/sql/Waiting for query cache lock                                     | NO      | NO    |
| stage/sql/Waiting for the next event in relay log                          | NO      | NO    |
| stage/sql/Waiting for the slave SQL thread to advance position             | NO      | NO    |
| stage/sql/Waiting to finalize termination                                  | NO      | NO    |
| stage/sql/Waiting for preceding transaction to commit                      | NO      | NO    |
| stage/sql/Waiting for dependent transaction to commit                      | NO      | NO    |
| stage/sql/Suspending                                                       | NO      | NO    |
| stage/sql/starting                                                         | NO      | NO    |
| stage/sql/Waiting for no channel reference.                                | NO      | NO    |
| stage/mysys/Waiting for table level lock                                   | NO      | NO    |
| stage/sql/Waiting on empty queue                                           | NO      | NO    |
| stage/sql/Waiting for next activation                                      | NO      | NO    |
| stage/sql/Waiting for the scheduler to stop                                | NO      | NO    |
| stage/sql/Waiting for global read lock                                     | NO      | NO    |
| stage/sql/Waiting for tablespace metadata lock                             | NO      | NO    |
| stage/sql/Waiting for schema metadata lock                                 | NO      | NO    |
| stage/sql/Waiting for table metadata lock                                  | NO      | NO    |
| stage/sql/Waiting for stored function metadata lock                        | NO      | NO    |
| stage/sql/Waiting for stored procedure metadata lock                       | NO      | NO    |
| stage/sql/Waiting for trigger metadata lock                                | NO      | NO    |
| stage/sql/Waiting for event metadata lock                                  | NO      | NO    |
| stage/sql/Waiting for commit lock                                          | NO      | NO    |
| stage/sql/User lock                                                        | NO      | NO    |
| stage/sql/Waiting for locking service lock                                 | NO      | NO    |
| stage/innodb/alter table (end)                                             | YES     | YES   |
| stage/innodb/alter table (flush)                                           | YES     | YES   |
| stage/innodb/alter table (insert)                                          | YES     | YES   |
| stage/innodb/alter table (log apply index)                                 | YES     | YES   |
| stage/innodb/alter table (log apply table)                                 | YES     | YES   |
| stage/innodb/alter table (merge sort)                                      | YES     | YES   |
| stage/innodb/alter table (read PK and internal sort)                       | YES     | YES   |
| stage/innodb/buffer pool load                                              | YES     | YES   |
+----------------------------------------------------------------------------+---------+-------+
129 rows in set (0.00 sec)

mysql> SELECT * FROM performance_schema.setup_instruments WHERE ENABLED='YES' AND NAME LIKE "stage/%";
+-----cleani-------------------------------------------------+---------+-------+
| NAME                                                 | ENABLED | TIMED |
+------------------------------------------------------+---------+-------+
| stage/sql/copy to tmp table                          | YES     | YES   |
| stage/innodb/alter table (end)                       | YES     | YES   |
| stage/innodb/alter table (flush)                     | YES     | YES   |
| stage/innodb/alter table (insert)                    | YES     | YES   |
| stage/innodb/alter table (log apply index)           | YES     | YES   |
| stage/innodb/alter table (log apply table)           | YES     | YES   |
| stage/innodb/alter table (merge sort)                | YES     | YES   |
| stage/innodb/alter table (read PK and internal sort) | YES     | YES   |
| stage/innodb/buffer pool load                        | YES     | YES   |
+------------------------------------------------------+---------+-------+
9 rows in set (0.01 sec)
```

### Enable EventsStagesHistory
`events_stages_history` は `events_stages_current` に依存している
```sql
mysql> UPDATE performance_schema.setup_consumers SET ENABLED = 'YES' WHERE NAME LIKE 'events_stages_current';
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> UPDATE performance_schema.setup_consumers SET ENABLED = 'YES' WHERE NAME LIKE 'events_stages_history';
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> UPDATE performance_schema.setup_instruments SET ENABLED = 'YES', TIMED = 'YES' WHERE NAME LIKE 'stage/sql/%';
Query OK, 119 rows affected (0.00 sec)
Rows matched: 120  Changed: 119  Warnings: 0
```

### Disable EventsStagesHistory
```sql
mysql> UPDATE performance_schema.setup_consumers SET ENABLED = 'NO' WHERE NAME LIKE 'events_stages_current';

mysql> UPDATE performance_schema.setup_consumers SET ENABLED = 'NO' WHERE NAME LIKE 'events_stages_history';

mysql> UPDATE performance_schema.setup_instruments SET ENABLED = 'NO', TIMED = 'NO' WHERE NAME LIKE 'stage/sql/%';

mysql> UPDATE performance_schema.setup_instruments SET ENABLED = 'YES', TIMED = 'YES' WHERE NAME = 'stage/sql/copy to tmp table';
```

