# Enabling GTID Transactions Online
Ref: https://dev.mysql.com/doc/refman/5.7/en/replication-mode-change-online-enable-gtids.html

1. on each server
```sql
SET @@GLOBAL.ENFORCE_GTID_CONSISTENCY = WARN;
```
* Let the server run for a while with your normal workload and monitor the logs.
* If this step causes any warnings in the log, adjust your application so that it only uses GTID-compatible features and does not generate any warnings.

2. on each server
```sql
SET @@GLOBAL.ENFORCE_GTID_CONSISTENCY = ON;
```

3. on each server
```sql
SET @@GLOBAL.GTID_MODE = OFF_PERMISSIVE;
```
* It does not matter which server executes this statement first, but it is important that all servers complete this step before any server begins the next step.

4. on each server
```sql
SET @@GLOBAL.GTID_MODE = ON_PERMISSIVE;
```
* It does not matter which server executes this statement first.

5. on each server, wait until the status variable `ONGOING_ANONYMOUS_TRANSACTION_COUNT` is zero. This can be checked using:
```sql
SHOW STATUS LIKE 'ONGOING_ANONYMOUS_TRANSACTION_COUNT';
```

6. Wait for all transactions generated up to step 5 to replicate to all servers.
* You can do this without stopping updates: the only important thing is that all anonymous transactions get replicated.
* If you use binary logs for anything other than replication, for example point in time backup and restore, wait until you do not need the old binary logs having transactions without GTIDs.
  * It is vital to understand that binary logs containing anonymous transactions, without GTIDs cannot be used after the next step.
  * After this step, you must be sure that transactions without GTIDs do not exist anywhere in the topology.

7. on each server
```sql
SET @@GLOBAL.GTID_MODE = ON;
```

8. On each server, add `gtid_mode=ON` and `enforce_gtid_consistency=ON` to my.cnf.
* if you use multi-source replication, do this for each channel and include the FOR CHANNEL channel clause:
```sql
STOP SLAVE [FOR CHANNEL 'channel'];
CHANGE MASTER TO MASTER_AUTO_POSITION = 1 [FOR CHANNEL 'channel'];
START SLAVE [FOR CHANNEL 'channel'];
```
