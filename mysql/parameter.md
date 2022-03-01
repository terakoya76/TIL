# my.cnf
Ref: https://dev.mysql.com/doc/refman/5.6/ja/server-system-variables.html

## client
```my.cnf
[mysql]
prompt = '\\u@\\h [\\d] > '
default_character_set = utf8mb4
safe_updates = 1
show_warnings = 1
connect_timeout = 5
ssl-cipher = 'DEFAULT:!EDH:!DHE'
pager = 'less -R'
```

## safe_updates = 1
以下の変数を有効化する
* sql_safe_updates=1
  * WHERE/LIMIT で絞っていない UPDATE/DELETE を防ぐ
* sql_select_limit=1000
  * SELECT から返される最大行数
* max_join_size=1000000
  * 検査が必要となる行数、または行の組み合わせの数が`max_join_size` をおそらく超えるか、disk seek が `max_join_size` 回を超えて実行される可能性がある statement を許可しません


## server collation
```my.cnf
[mysqld]
# collation
character_set_server = utf8mb4

## required from MySQL8.0
### for JPN, based on Unicode Collation Algorithm 9.0.0, accent sentitive, case sentitive
# collation_server = utf8mb4_ja_0900_as_cs

lower_case_table_names = 1
```

## server network
```my.cnf
[mysqld]
bind-address = 127.0.0.1
port = 3306

skip_name_resolve
max_allowed_packet = 16M
max_connections = 1000
open_files_limit = 65536
max_connect_errors = 10000
wait_timeout = 60
slave_net_timeout = 60
```

### skip_name_resolve
client 接続を検査するときにホスト名を解決しません。
* このオプションを使用する場合、付与 table のすべての Host column の値は IP または localhost である必要があります

#### DNS ルックアップの最適化とホストキャッシュ
Ref https://dev.mysql.com/doc/refman/5.6/ja/host-cache.html

MySQL server は client に関する情報 (IP、hostname、エラー情報) を格納する host-cache を memory に保持します。server はこの cache を non-local TCP 接続に使用します

server は次のように host-cache 内のエントリを処理します。
* 最初の TCP client 接続が指定された IP から server に到達すると、client IP、hostname、および host client 検証フラグを記録する新しいエントリが作成されます。
  * 最初に、hostname が NULL に設定され、フラグは false になります。このエントリは同じ発信元 IP からの後続の client 接続にも使用されます。
* client IP エントリの検証フラグが false の場合、server は IP から hostname への DNS の解決を試みます。
  * それが成功した場合、hostname が解決された hostname で更新され、検証フラグが true に設定されます。
  * 解決が成功しない場合、取られるアクションは、エラーが永続的か一時的かによって異なります。
    * 永続的なエラーの場合、hostname は NULL のままになり、検証フラグは true に設定されます。
    * 一時的なエラーの場合、hostname と検証フラグは変更されないままになります。(次回に client がこの IP から接続したときは、別の DNS 解決の試みが行われます。)
* 特定の IP からの着信 client 接続の処理中にエラーが発生した場合、server はその IP のエントリ内の対応するエラーカウンタを更新します。

server はいくつかの目的で host-cache を使用します。
* IP から hostname への lookup の結果を cache することによって、server は client 接続ごとの DNS lookup の実行を回避します。
* cache には、接続プロセス中に発生したエラーに関する情報が格納されます。
  * 一部のエラーは「ブロッキング」とみなされます。
  * 成功した接続がない特定のホストから、これらの多くが連続して発生している場合、server はそのホストからのその後の接続をブロックします。
  * `max_connect_errors` システム変数は、ブロックが行われるまで許可されるエラーの数を指定します。

### max_allowed_packet
1つの packet、生成された文字列または中間文字列、または `mysql_stmt_send_long_data()` C API 関数によって送信されたすべてのパラメータの最大サイズ
* 大きい BLOB column または長い文字列を使用している場合、この値を大きくする必要があります。
* 使用する最大の BLOB と同じ大きさにしてください。`max_allowed_packet` のプロトコル制限は 1G バイトです。値は 1024 の倍数にします。倍数でない場合、もっとも近い倍数に切り下げられます。

### open_files_limit
mysqld が利用できる fd 数を指定する

### max_connections
許可される最大の client の同時接続数。
* この値を大きくすると、mysqld が要求する fd の数が増加します。
* 必要な数の fd が利用できない場合、server は `max_connections` の値を削減します。

### wait_timeout
非 interactive な接続を閉じる前に、server がその接続上で activity を待機する秒数

### slave_net_timeout
* master からの後続のデータを待機する秒数 (これ以降は、slave は接続が切断されていると見なし、読み取りを中止し、再接続を試行)。
* 最初の再試行は timeout の直後に発生します。
* 再試行の間隔は CHANGE MASTER TO statement の MASTER_CONNECT_RETRY オプションで制御され、再接続の試行回数は `--master-retry-count` オプションによって制限されます。
* デフォルトは 3600 秒 (1 時間) です。

## server cache
```my.cnf
table_open_cache = 2000
thread_cache_size = 100
query_cache_type = 0
query_cache_size = 0
binlog_cache_size = 16M
max_heap_table_size = 64M
tmp_table_size = 64M
```

### table_open_cache
すべての thread について開いている table の数

### thread_cache_size
server が再使用のために cache する thread の数
* client が接続を切断したとき、thread 数が `thread_cache_size` より少なければ、client の thread は cache に配置されます。
* thread のリクエストは可能であれば、cache からの thread を再使用することによって満たされ、cache が空の場合のみ新しい thread が作成されます。
* 多くの新しい接続がある場合、この変数を増やしてパフォーマンスを向上できます

### query_cache_type, query_cache_size
query cache type の設定および query 結果を cache するために割り当てられた memory の量

query cache type
* 0
  * query cache に結果を cache したり、query cache から結果を取得したりしません。
  * これは query cache bufer を割り当て解除しません。これを行うには `query_cache_size` を0に設定します。
* 1
  * SELECT SQL_NO_CACHE で始まるものを除く cache 可能なすべての query 結果を cache します。
* 2
  * または DEMAND SELECT SQL_CACHE で始まる cache 可能な query のみ結果を cache します。

### max_heap_table_size, tmp_table_size
Ref: https://dev.mysql.com/doc/refman/5.6/ja/internal-temporary-tables.html

内部一時 table のサイズを制限する
* server は query の処理中に内部一時 table を作成します。
* それらの table は memory 内に保持して、MEMORY storage engine によって処理したり、disk 上に格納して、MyISAM storage engine によって処理したりできます。
* server は最初に in-memory table として内部で一時 table を作成し、それが大きくなりすぎた場合に、それを disk 上 table に変換することがあります。
* server が内部一時 table を作成するタイミングや、server がそれを管理するためにどの storage engine を使用するかに関して、ユーザーは直接制御できません

一時 table は、次のような条件で作成される可能性があります。
EXPLAIN を使用し、Extra column をチェックして、そこに Using temporary と示されているかどうかを確認すると実際に使用したかわかる
* UNION query が一時 table を使用します。
* TEMPTABLE アルゴリズムを使用して評価されるものや、UNION または aggregation を使用するものなど、一部の view で一時 table を必要とします。
* ORDER BY 句と別の GROUP BY 句がある場合、または、ORDER BY または GROUP BY に結合 queue 内の最初の table と異なる table の column が含まれている場合は、一時 table が作成されます。
* DISTINCT と ORDER BY の組み合わせで、一時 table が必要になることがあります。
* SQL_SMALL_RESULT オプションを使用すると、MySQL では query に disk 上 storage を必要とする要素も含まれていないかぎり、in-memory 一時 table が使用されます。
* 複数 table  UPDATE statement。
* GROUP_CONCAT() または COUNT(DISTINCT) 評価。
* 派生 table (FROM 句内の subquery)。
* subquery または準結合実体化のために作成される table 。

内部一時 table が最初に in-memory table として作成されたが、これが大きくなりすぎた場合、MySQL はこれを自動的に disk 上の table に変換します。in-memory 一時 table の最大サイズは、`tmp_table_size` と `max_heap_table_size` の最小値です

## server log
```my.cnf
## error log
log_error = mysql-error.log

## general log
# general_log = 1
# general_log_file = mysql.log

## slow query log
slow_query_log = 1
slow_query_log_file = mysql-slow.log
long_query_time = 0.1
log_slow_admin_statements
log_slow_slave_statements

## performance_schema
performance_schema = ON
performance_schema_instrument = '%=off'
```

## server innodb
```my.cnf
innodb_strict_mode = 1
innodb_buffer_pool_size = 1G
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_buffer_size = 16M
innodb_log_file_size = 512M
innodb_doublewrite = 1
innodb_read_io_threads = 8
innodb_write_io_threads = 8
innodb_lock_wait_timeout = 5
innodb_support_xa = 1
innodb_autoinc_lock_mode = 2
innodb_flush_log_at_trx_commit = 1
innodb_flush_method = O_DIRECT
innodb_file_per_table = 1
innodb_print_all_deadlocks = 1

## removed from MySQL8.0
innodb_file_format = Barracuda
innodb_large_prefix = 1
innodb_undo_tablespaces = 2
```

### innodb_lock_wait_timeout
行ロックが解除されるまで InnoDB trx が待機する時間の長さ (秒単位) です。デフォルト値は 50 秒です。
別の InnoDB trx でロックされている行へのアクセスを試みる trx は、行への書き込みアクセスを最大でこの秒数間待機してから、エラーを発行します。

### innodb_support_xa
trx の準備時に追加の disk flush が発生します。
* XA メカニズムは内部で使用されるため、binary logging がオンになっていて、複数のスレッドからのデータの変更が許可されている任意の server で重要となります。
* オフにすると、ライブデータベースが commit するときとは異なる順序で、trx が binlog に書き込まれる可能性があります。
* これにより、DR 時や replication slave で binary log が再現されるときに、異なるデータが生成される可能性があります。

### innodb_autoinc_lock_mode
自動インクリメント値を生成する際に使用されるロックモードです（デフォルトは1）
* 0（従来）
* 1（連続）
* 2（インターリーブ）

### Disk I/O Tuning
Ref: https://dev.mysql.com/doc/refman/5.6/ja/optimizing-innodb-diskio.html

* GNU/Linux および Unix の一部のバージョンでは、Unix fsync() 呼び出しおよび類似のメソッドによるファイルのディスクへのフラッシュが驚くほど低速です。
  * データベースの書き込みパフォーマンスが問題である場合、`innodb_flush_method` パラメータを `O_DSYNC` に設定してベンチマークを実行します
* スループットが周期的に低下する場合、`innodb_io_capacity` 構成オプションの値を増加することを考慮します。値を大きくすると、フラッシュが頻繁になり、スループットを低下させる可能性のある作業のバックログが避けられます
  * `innodb_io_capacity` は InnoDB バックグラウンドタスクで実行される I/O アクティビティー (buffer pool からのページのフラッシュや挿入バッファーからのデータのマージなど) に上限を設定します。


## server replication
```my.cnf
server_id = <%= server_id %>
report_host = <%= report_host %>

log_bin = mysql-bin
relay_log = mysql-relay-bin
log_slave_updates
binlog_order_commits

binlog_format = ROW
max_binlog_size = 512M
expire_logs_days = 10
sync_binlog

## gtid
gtid_mode = ON
enforce_gtid_consistency
binlog_checksum=NONE
master_info_repository=TABLE
relay_log_info_repository=TABLE
```

## server SQL_MODE
```my.cnf
sql_mode = TRADITIONAL,NO_AUTO_VALUE_ON_ZERO,ONLY_FULL_GROUP_BY
```

### kamipo traditional
Ref: https://songmu.jp/riji/entry/2015-07-08-kamipo-traditional.html

### SQL MODE
Ref: https://dev.mysql.com/doc/refman/5.6/ja/sql-mode.html

Traditional
* `STRICT_TRANS_TABLES`、`STRICT_ALL_TABLES`、`NO_ZERO_IN_DATE`、`NO_ZERO_DATE`、`ERROR_FOR_DIVISION_BY_ZERO`、`NO_AUTO_CREATE_USER`、および `NO_ENGINE_SUBSTITUTION` と同等です
* MySQL を従来型の SQL database system のように動作させます。このモードを簡単に説明すると、column に不正な値を挿入したときに警告ではなくエラーを返します

NO_AUTO_VALUE_ON_ZERO
* NO_AUTO_VALUE_ON_ZERO は AUTO_INCREMENT column の処理に影響します。
* 通常は、NULL または 0 を column に挿入することによって、column の次のシーケンス番号を生成します。
* NO_AUTO_VALUE_ON_ZERO は 0 のこの動作を抑制するため、NULL のみが次のシーケンス番号を生成します

ONLY_FULL_GROUP_BY
* GROUP BY 句で名前が指定されていない非集約 column を、選択リスト、HAVING 条件、または ORDER リストが参照する query を拒否します
