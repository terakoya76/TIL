## Scalability Tuning
Ref: https://www.slideshare.net/yasufumikinoshita10/inno-db-deeptalk2

### Innodb 以外の設定
I/O Scheduler
* elevator = deadline
* mount option = noatime

my.cnf
* max_connections
  * utilization を確認
* table_open_cache
  * resource 不足だと自動で縮小されてしまうので起動後に確認
* tmpdif
  * ALTER で tmpfile が使用されるので高速なストレージを指定
* query_cache_type = OFF
* metadata_locks_hash_instances
  * MDL 関連の mutex 競合が目立つなら増やすと良い
* table_open_cache_instances
  * table_cache の mutex 競合が目立つなら増やすと良い

allocator
* jemalloc

### Innodb の設定
* innodb_flush_method = O_DIRECT
  * データファイルアクセスにメモリを無駄に食わないため
* innodb_doublewrite = false
  * ページ単位の中途書き込み状態を別の手段で防げれば無効化したい
* innodb_buffer_pool_size
  * 可能な限り大きくするが、他の処理用の disk cache 分残す
* innodb_log_file_size
  * recovery 時間とのトレードオフだができるだけ大きくする
* innodb_log_files_in_group = 2
* innodb_change_buffer_max_size = 1
  * 溜め込んで buffer pool を浪費しないよう小さい値
* innodb_checksum_algorithm = crc32
  * 早ければ早いほどよい
* innodb_purge_threads
  * ユーザスレッドの更新に負けない個数設定
* innodb_sync_array_size
  * sync array の mutex 競合が多い場合は増やす
* innodb_page_cleaners
  * ユーザスレッドに負けないように(実質並列度の最大は buffer_pool_instances の数)
* innodb_io_capacity_max の見直し(大きい値を設定している場合)
* 各表への MERGE_THRESHOLD 指定
  * デフォルトの50%より少し下げて BTR_MODIFY_TREE の発生を抑える
