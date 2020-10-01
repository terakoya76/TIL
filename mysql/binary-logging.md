## Binary Logging

Ref:
* https://dev.mysql.com/doc/refman/5.6/ja/binary-log.html
* https://dev.mysql.com/doc/internals/en/binary-log.html

### Summary
1. master で更新処理実行中の各 thread が、各々の変更を内容を memory cache に書き溜めていく
2. innodb で `PREPARE` する(5.7.10 以降、`innodb_support_xa` は常に true)
3. cache から一連の更新処理を `BEGIN/COMMIT` で挟んで binlog に書く
4. innodb で `COMMIT` する

### Binlog Buffer
* trx を処理する thread が開始すると、thread は `binlog_cache_size` の buffer を buffer statement に割り当てます。
  * statement がこれより大きい場合、thread は trx 格納する一時ファイルを開きます。thread が終了すると、一時ファイルは削除されます。
* `max_binlog_cache_size` システム変数 (default は最大値の 4G) を使用して、複数 statement の trx を cache するために使用する合計サイズを制限することができます。
  * trx がこのバイト数より大きくなると、失敗して rollbak します。
* binlog への `COMMIT` が終わってから storage-engine への `COMMIT` が行う 2PC により commit procedure は行われるので、binlog にだけ存在する trx が存在しうるが、`--innodb_support_xa` が default の 1 に設定されていると server の recovery の一環として binlog から `COMMIT` されていない trx の purge が行われ、ここの同期が保証されるようになる

### Commit Procedure
* https://github.com/mysql/mysql-server/blob/mysql-5.7.12/sql/handler.cc#L1604
* https://github.com/mysql/mysql-server/blob/mysql-5.7.12/sql/binlog.cc#L8698

### Group Commit
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

#### Traditional Binary Logging
session <-> server <-> engine の layer があった時、storage-engine/binlog 間の整合性を 2PC で保っている。
この 2PC の間に crash が起きた場合の recovery は、storage-engine が prepared trx を server に提供し、server はそれらの trx が binlog 上に存在すれば storage-engine にも commit し、そうでなかった場合は rollback を行う。storage-engine よりも先に binlog への commit が走る必要があるので `fsync()` が必要になる
1. session -> server の `COMMIT`
2. server -> engine の `PREPARE`
3. server -> binlog に `write()`, `fsync()`
4. server -> engine の `COMMIT` が成功
5. session -> server の `COMMIT` が成功

`prepare_commit_mutex`
* 上記の storage-engine よりも先に binlog へ commit が走る制約は `on-line backup methods such as InnoDB Hot Backup` などを利用した際に崩れうる。
* これらの tool は database files を直接 backup するので、`COMMIT` されていないが `PREPARE` はされている trx が storage-engine に残るケースが有る。
* 通常 storage-engine 側を rollback すればいいだけだが、innodb REDO log には `last committed transaction position` が書き込まれており、それを使って backup から slave を作るというユースケースが存在する。この場合、binlog/storage-engine 間で commit order がずれると slave 側で `COMMIT` されてないが `PREPARE` されていた trx の欠損が発生しうる。
* `prepare_commit_mutex` という storage-engine に `PREPARE` を打つ際に取得し、`COMMIT` 時に開放される。これにより各 trx は serialize される。

`sync_binlog`
1 が設定されると binlog に書き込みが成功したタイミングで必ず `fsync()` が呼ばれる。

#### Binary Logging Group Commit
group commit の idea は binlog に対する複数の trx からの `write()` を都度 `fsync()` する代わりに、更新内容をまとめて batch で `fsync()` すること。
* ただし先述した問題から `prepare_commit_mutex` を利用せずに `PREPARE` order と `write()` order を一致させる必要がある

group commit は binlog に対する `fsync()`, `COMMIT` を flush/sync/commit の 3stage に分解する。
* 各 stage は session の queue を同時に1つまで処理する。その間次の queue はその stage の前で待機する。
* 最初に enqueue された session は leader となり、後続 session が follower となる。leader は 3stage を通して 自分の queue の sessions を次の queue に運ぶ責務を持ち、follower は leader が全体の `COMMIT` 完了 signal を送るまで待機し続ける。
* step 間で Leader は non-empty-queue に自身を enqueeu し follower になることがあるが、follower が leader になることはない。

stage responsibility
* In the flush stage
  * trx cache を binary log に書き出す。
  * ここではあくまで in-memory file page に書き出すだけで disk には書き出されていない
  * `binlog_max_flush_queue_time` の間、input queue の last session が remove されない、もしくは first session が unqueue されない場合、leader は queue を次の stage に処理をすすめる

* In the sync stage
  * `sync_binlog` の設定に従い in-memory binlog page を disk に書き出す

* In the commit stage
  * session は queue に enqueue された順番に storage-engine へ commit されることで commit order は保存される
  * commit stage が完了すると、signal で通史を行うことで各 sessions は commit procedure を再開していく

### innodb_support_xa
* `innodb_support_xa=true` の時、`PREPARE` の時に undo log に xid が書き込まれる
* crash recovery 時に xid のない `PREPARE` trx は rollback されるが、xid 付きの場合は、binlog から xid を取得できた場合、binlog から storage-engine に commit してくれる

参照
* https://github.com/mysql/mysql-server/blob/mysql-5.7.12/storage/innobase/handler/ha_innodb.cc#L16663
* https://github.com/mysql/mysql-server/blob/mysql-5.7.12/sql/binlog.cc#L9007
* https://github.com/mysql/mysql-server/blob/mysql-5.7.12/storage/innobase/handler/ha_innodb.cc#L16758
* https://github.com/mysql/mysql-server/blob/mysql-5.7.12/storage/innobase/handler/ha_innodb.cc#L16780
