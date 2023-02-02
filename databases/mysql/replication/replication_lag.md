# Replication Lag

Ref:
* https://dev.mysql.com/doc/refman/8.0/en/faqs-replication.html#faq-replication-how-compare-replica-date

replication SQL thread が source から読み込んだ event を実行すると、event の timestamp に自分の時間を修正します。
`SHOW PROCESSLIST` の出力の Time 列では、replication SQL thread に表示される秒数は、最後に replication された event の timestamp と replica machine の実時間との間の秒数です。
これを使用して、最後に replicate された event の日付を判断することができます。

replica が1時間 source から切断された後に再接続した場合、`SHOW PROCESSLIST` の replication SQL thread に 3600 のような大きな Time 値がすぐに表示される可能性があることに注意してください。
これは、replica が1時間前の statement を実行しているためです。

## Identify Replication Lag
Ref: https://www.percona.com/blog/2014/05/02/how-to-identify-and-cure-mysql-replication-slave-lag/

### Identify
IO Thread
`SHOW MASTER STATUS - SHOW SLAVE STATUS`
* Master_Log_File
* Read_Master_Log_Pos

SQL Thread
`Read_Master_Log_Pos - Exec_Master_Log_Pos`

### Cause Detection
IO Thread
* the slow network between master/slave.
  * enabling `slave_compressed_protocol` helps to mitigate
  * disable binary logging on slave as it’s IO intensive too

SQL Thread
* fix query
  * enable `log_slow_slave_statements` helps to make the load on slave
  * set `log_slow_verbosity` to `full`
