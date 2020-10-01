## Multi Thread Slave

Ref:
* https://www.slideshare.net/takanorisejima/mysql57-ga-multithreaded-slave

```my.cnf
[mysqld]

# enable binary logging
# should be enable on master/slave
log_bin=mysql-bin
log_slave_updates = 1
binlog_order_commits = 1

# decide by running bench on your own environment
slave_parallel_workers = 32

# Group Commit された entries を並列処理
# binlog_group_commit_sync_delay, binlog_group_commit_sync_no_delay_count を環境ごとに調整する必要あり
# Default の DATABASE だと同一 database 上では並列化が効かず旨味がない
slave_parallel_type = LOGICAL_CLOCK

# ensure same commit order b/w master and slave
slave_preserve_commit_order = 1

# crash safety
relay_log_info_repository = TABLE
relay_log_recovery = ON
relay_log_purge = ON
```
### binlog_group_commit_sync_delay
* binlog 同期する前に待つ時間(ms)
* wait を増やせばその分多くの entry を group commit に含められる
* response time は悪化するが throughput は上がる

### binlog_group_commit_sync_no_delay_count
* 1 commit に含められる max trx 数

### LOGICAL_CLOCK
Ref:
* https://dev.mysql.com/worklog/task/?id=6314
* https://en.wikipedia.org/wiki/Lamport_timestamp

binlog に gtid_event の一部として logical timestamp を書き込んでおり、それを元に並列実行可能かを決定する
`GTID_MODE=OFF` でも anonymous_gtid_event が binlog には書き込まれているので処理は同様
* `last_committed`
  * master で commit 済みの trx の内、最大の `sequence_number`
* `sequence_number`
  * master で binlog に trx を flush する度に increment される

下記の順序で binlog に書き込まれる
1. gtid_event(anonymous_gtid_event)
2. `BEGIN`
3. statement or row
4. `COMMIT`

並列実行可能かは
* 対象の trx の `last_committed` が slave で実行された trx の `sequence_number` によって更新されていく `last_lwm_timestamp` よりも小さければ可能
* binlog entry を眺めて `last_committed` が同じ trx がたくさんあった場合、それらは並列実行可能なので、その workload では MTS により性能向上が見込めるという予測が立てられる

参考
* https://github.com/mysql/mysql-server/blob/mysql-5.7.12/sql/binlog.cc#L1391

### MTS and Consistency
MTS and SBR or Non-Deterministic Query はアカン
* INSERT ... SELECT など、MTS だと slave ごとに結果が変わってしまう

MTS and Read-Uncommiteed もアカン
* MTS で保証可能なのは binlog からの commit order なので

### MTS and GTID
Ref: https://dev.mysql.com/doc/refman/5.7/en/replication-features-transaction-inconsistencies.html

GTID は有効にしないとアカン
* `Exec_Master_Log_Pos` の意味が変わってしまう（`mysql.slave_worker_info` の `Checkpoint_master_log_pos` が `Exec_Master_Log_Pos` になる）
  * MTS では GAQ の checkpoint のタイミングで `Exec_Master_Log_Pos` などが更新されるので realtime 性は失われる。
  * relay log をどこまで適用したかは `SHOW SLAVE STATUS` からはわからなくなる。
  * 特定の event だけ skip するというのが難しい（`sql_slave_skip_counter`）
    * https://dev.mysql.com/doc/refman/5.6/ja/set-global-sql-slave-skip-counter.html

GAQ(Group Assigned Queue)
* coordinator thread が relay log から binlog event を読み出して worker thread にわたすときに使う固定長 queue
* trx という job の group をどの worker thread に assign して実行完了したかどうかを管理
* checkpoint 処理は下記で行われる
  * GAQ を使い切る
  * `slave_checkpoint_group` 回 trx を実行
  * `slave_checkpoint_period` msec 経過
* checkpoint 処理の内容
  * 実行完了した trx entry を GAQ から削除
  * SHOW SLAVE STATUS で表示される情報を更新
  * GAQ.lwm を更新
    * これが最終的に `last_lwm_timestamp` を更新
