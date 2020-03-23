# Replication Lag

Ref:
* https://dev.mysql.com/doc/refman/8.0/en/faqs-replication.html#faq-replication-how-compare-replica-date

replication SQL threadがsourceから読み込んだeventを実行すると、eventのタイムスタンプに自分の時間を修正します。
`SHOW PROCESSLIST` の出力のTime列では、replication SQL threadに表示される秒数は、最後にreplicationされたeventのタイムスタンプとreplica machineの実時間との間の秒数です。
これを使用して、最後にreplicateされたeventの日付を判断できます。

replicaが1時間sourceから切断された後に再接続した場合、`SHOW PROCESSLIST` のreplication SQL threadに3600のような大きなTime値がすぐに表示される可能性があることに注意してください。
これは、replicaが1時間前のstatementを実行しているためです。

## Identify Replication Lag
Ref: https://www.percona.com/blog/how-to-identify-and-cure-mysql-replication-slave-lag/

### Identify
I/O Thread
`SHOW MASTER STATUS - SHOW SLAVE STATUS`
* `Master_Log_File`
* `Read_Master_Log_Pos`

SQL Thread
`Read_Master_Log_Pos - Exec_Master_Log_Pos`

### Cause Detection
I/O Thread
* the slow network between `master/slave`.
  * enabling `slave_compressed_protocol` helps to mitigate
  * disable binary logging on slave as it’s I/O intensive too

SQL Thread
* fix query
  * enable `log_slow_slave_statements` helps to make the load on slave
  * set `log_slow_verbosity` to `full`
