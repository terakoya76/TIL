# Binary Logging

Ref:
* https://dev.mysql.com/doc/refman/8.0/ja/binary-log.html
* https://dev.mysql.com/doc/dev/mysql-server/latest/

## Summary
1. `master` で更新処理実行中の各threadが、各々の変更を内容をmemory cacheに書き溜めていく
2. innodbで `PREPARE` する（5.7.10以降、`innodb_support_xa` は常にtrue)
3. cacheから一連の更新処理を `BEGIN/COMMIT` で挟んでBinlogに書く
4. innodbで `COMMIT` する

## Binlog Buffer
* trxを処理するthreadが開始すると、threadは `binlog_cache_size` のbufferを `buffer statement` に割り当てます。
  * statementがこれより大きい場合、threadはtrx格納する一時ファイルを開きます。threadが終了すると、一時ファイルは削除されます。
* `max_binlog_cache_size` システム変数 (defaultは最大値の4G) を使用して、複数statementのtrxをcacheするために使用する合計サイズを制限できます。
  * trxがこのバイト数より大きくなると、失敗してrollbackします。
* Binlogへの `COMMIT` が終わってから `StorageEngine` への `COMMIT` が行う `2PC` によりcommit procedureは行われるので、Binlogにだけ存在するtrxが存在しうるが、`--innodb_support_xa` がdefaultの1に設定されているとserverのrecoveryの一環としてBinlogから `COMMIT` されていないtrxのpurgeが行われ、ここの同期が保証されるようになる

## Commit Procedure
* https://github.com/mysql/mysql-server/blob/mysql-5.7.12/sql/handler.cc#L1604
* https://github.com/mysql/mysql-server/blob/mysql-5.7.12/sql/binlog.cc#L8698

## Group Commit
Ref: http://mysqlmusings.blogspot.com/2012/06/binary-log-group-commit-in-mysql-56.html

```my.cnf
[mysqld]

# If this is off (0), transactions may be committed in parallel.
# In some circumstances, this might offer some performance boost.
# For the measurements we did, there were no significant improvement in throughput, but we decided to keep the option anyway since there are special cases were it can offer improvements.
binlog_order_commits={0|1}

# This variable controls when to stop skimming the flush queue and move on as soon as possible.
# Note that this is not a timeout on how often the binary log should be written to disk since grabbing the queue and writing it to disk takes time.
binlog_max_flush_queue_time=<microseconds>
```

### Traditional Binary Logging
`session <-> server <-> StorageEngine` のlayerがあったとき、`StorageEngine/Binlog` 間の整合性を `2PC` で保っている。
この2PCの間にcrashが起きた場合のrecoveryは、`StorageEngine` がprepared trxをserverに提供し、serverはそれらのtrxがBinlog上に存在すれば `StorageEngine` にもcommitし、そうでなかった場合はrollbackを行う。`StorageEngine` よりも先にBinlogへのcommitが走る必要があるので `fsync()` が必要になる
1. `session -> server` の `COMMIT`
2. `server -> StorageEngine` の `PREPARE`
3. `server -> Binlog` に `write()`, `fsync()`
4. `server -> StorageEngine` の `COMMIT` が成功
5. `session -> server` の `COMMIT` が成功

`prepare_commit_mutex`
* 上記の `StorageEngine` よりも先にBinlogへcommitが走る制約は `on-line backup methods such as InnoDB Hot Backup` などを利用した際に崩れうる。
* これらのtoolはdatabase filesを直接backupするので、`COMMIT` されていないが `PREPARE` はされているtrxが `StorageEngine` に残るケースがある。
* 通常 `StorageEngine` 側をrollbackすればよいだけだが、innodb REDO logには `last committed transaction position` が書き込まれており、それを使ってbackupからslaveを作るというユースケースが存在する。この場合、`StorageEngine/Binlog` 間でcommit orderがずれるとslave側で `COMMIT` されてないが `PREPARE` されていたtrxの欠損が発生しうる。
* `prepare_commit_mutex` という `StorageEngine` に `PREPARE` を打つ際に取得し、`COMMIT` 時に開放される。これにより各trxはserializeされる。

`sync_binlog`
1が設定されるとBinlogに書き込みが成功したタイミングで必ず `fsync()` が呼ばれる。

### Binary Logging Group Commit
group commitのideaはBinlogに対する複数のtrxからの `write()` を都度 `fsync()` する代わりに、更新内容をまとめてbatchで `fsync()` すること。
* ただし先述した問題から `prepare_commit_mutex` を利用せずに `PREPARE` orderと `write()` orderを一致させる必要がある

group commitはBinlogに対する `fsync()`, `COMMIT` をflush/sync/commitの3stageに分解する。
* 各stageは`session`のqueueを同時に1つまで処理する。その間次のqueueはそのstageの前で待機する。
* 最初にenqueueされた`session`はleaderとなり、後続`session`がfollowerとなる。leaderは3stageを通して自分のqueueの`session`を次のqueueに運ぶ責務を持ち、followerはleaderが全体の `COMMIT` 完了signalを送るまで待機し続ける。
* step間でLeaderはnon-empty-queueに自身をenqueeuしfollowerになることがあるが、followerがleaderになることはない。

stage responsibility
* In the flush stage
  * trx cacheをbinary logに書き出す。
  * ここではあくまでin-memory file pageに書き出すだけでdiskには書き出されていない
  * `binlog_max_flush_queue_time` の間、input queueのlast`session`がremoveされない、もしくはfirst`session`がunqueueされない場合、leaderはqueueを次のstageに処理を進める

* In the sync stage
  * `sync_binlog` の設定に従いin-memory Binlog pageをdiskに書き出す

* In the commit stage
  * `session`はqueueにenqueueされた順番に `StorageEngine` へcommitされることでcommit orderは保存される
  * commit stageが完了すると、signalで通史を行うことで各`sessions`はcommit procedureを再開していく

## innodb_support_xa
* `innodb_support_xa=true` の時、`PREPARE` の時にundo logにxidが書き込まれる
* crash recovery時にxidのない `PREPARE` trxはrollbackされるが、xid付きの場合は、Binlogからxidを取得できた場合、Binlogから `StorageEngine` にcommitしてくれる

参照
* https://github.com/mysql/mysql-server/blob/mysql-5.7.12/storage/innobase/handler/ha_innodb.cc#L16663
* https://github.com/mysql/mysql-server/blob/mysql-5.7.12/sql/binlog.cc#L9007
* https://github.com/mysql/mysql-server/blob/mysql-5.7.12/storage/innobase/handler/ha_innodb.cc#L16758
* https://github.com/mysql/mysql-server/blob/mysql-5.7.12/storage/innobase/handler/ha_innodb.cc#L16780
