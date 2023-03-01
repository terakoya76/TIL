# Streaming Replication
* https://www.fujitsu.com/jp/products/software/resources/feature-stories/postgres/article-index/streaming-replication1/

## Where is Data Directory

```bash
$ sudo -u postgres psql -c "SHOW data_directory;"
        data_directory
------------------------------
 /var/lib/postgresql/10/main
(1 row)
```

## postgres.conf

```diff
# https://www.postgresql.jp/document/10/html/wal-configuration.html
-#wal_level = minimal                    # minimal, replica, or logical
+wal_level = hot_standby                 # minimal, replica, or logical

# https://www.fujitsu.com/jp/products/software/resources/feature-stories/postgres/article-index/streaming-replication1/
-synchronous_commit = off                # synchronization level;
+synchronous_commit = on                 # synchronization level;

-#wal_log_hints = off                    # also do full page writes of non-critical updates
+wal_log_hints = on                      # also do full page writes of non-critical updates

# https://www.postgresql.jp/document/10/html/runtime-config-replication.html
#
# hot_standby 台数 + 1 が基本
# basebackup などを使いたくなったときのために更に +1 で、1+1+1 = 3
-#max_wal_senders = 0            # max number of walsender processes
+max_wal_senders = 4             # max number of walsender processes

# https://www.postgresql.jp/document/10/html/runtime-config-replication.html
#
# standby が過去のファイルセグメントを取得する必要がある場合に備え、pg_xlogディレクトリに保持しておくファイルセグメント数の最小値を指定します。
# min_wal_size = 80MB / wal_buffer_size = 16MB = 5 がデフォルト
-#wal_keep_segments = 0          # in logfile segments, 16MB each; 0 disables
+wal_keep_segments = 32          # in logfile segments, 16MB each; 0 disables

# https://www.postgresql.jp/document/10/html/runtime-config-replication.html
#
# replication 非活動時間の閾値。これを超えると replication が死んでる判定
-#wal_sender_timeout = 60s       # in milliseconds; 0 disables
+wal_sender_timeout = 30s        # in milliseconds; 0 disables

# https://www.postgresql.jp/document/10/html/runtime-config-replication.html
#
# hot_standby 台数が必要。障害時にガチャガチャやりたいとき用に +1 で、2+1=3
-#max_replication_slots = 0      # max number of replication slots
+max_replication_slots = 3       # max number of replication slots

# https://www.postgresql.jp/document/10/html/runtime-config-replication.html
#
# recovery.conf で指定する application name
# 同一名 standby を複数台持つと、sync standby の冗長化ができる。
-#synchronous_standby_names = '' # standby servers that provide sync rep
+synchronous_standby_names = 'hot_standby' # standby servers that provide sync rep

# https://www.postgresql.jp/document/10/html/runtime-config-replication.html
-#hot_standby = off                      # "on" allows queries during recovery
+hot_standby = on                        # "on" allows queries during recovery

# https://www.postgresql.jp/document/10/html/runtime-config-replication.html
#
# max_standby_archive_delay < wal_sender_timeout/2 くらいを目安に
-#max_standby_archive_delay = 30s        # max delay before canceling queries
+max_standby_archive_delay = 15s          # max delay before canceling queries

# https://www.postgresql.jp/document/10/html/runtime-config-replication.html
#
# max_standby_archive_delay < wal_sender_timeout/2 くらいを目安に
-#max_standby_streaming_delay = 30s      # max delay before canceling queries
+max_standby_streaming_delay = 15s        # max delay before canceling queries

# https://www.postgresql.jp/document/10/html/runtime-config-replication.html
#
# max_standby_archive_delay < wal_sender_timeout/3 くらいを目安に
-#wal_receiver_status_interval = 10s     # send replies at least this often
+wal_receiver_status_interval = 10s     # send replies at least this often

# https://www.postgresql.jp/document/10/html/runtime-config-replication.html
-#hot_standby_feedback = off             # send info from standby to prevent
+hot_standby_feedback = on               # send info from standby to prevent

# https://www.postgresql.jp/document/10/html/runtime-config-replication.html
#
# replication 非活動時間の閾値。これを超えると replication が死んでる判定
-#wal_receiver_timeout = 60s             # time that receiver waits for
+wal_receiver_timeout = 30s              # time that receiver waits for

# https://www.postgresql.jp/document/10/html/runtime-config-replication.html
-#wal_retrieve_retry_interval = 5s       # time to wait before retrying to
+wal_retrieve_retry_interval = 5s       # time to wait before retrying to
```

## crash recovery

standby 側を basebackup から restore した際の crash recovery 方法を指定する
* https://www.postgresql.jp/docs/10/recovery-target-settings.html
```recovery.conf
standby_mode = 'on'
primary_conninfo = 'host=xxx port=xxx user=xxx password=xxx application_name=hot_standby'
recovery_target_timeline = 'latest'
```

## Recovery Procedure
### Master Failure
setup new master(old standby)
```bash
$ ssh standby

# hot_standby = on →  off
$ sudo vim /etc/postgresql/10/main/postgresql.conf

$ sudo rm /var/lib/postgresql/10/main/recovery.conf

# start as master
$ sudo -u postgres /usr/lib/postgresql/10/bin/pg_ctl reload -D /var/lib/postgresql/10/main
```

setup new standby
```bash
#
$ ssh old-master

# standby_mode = off →  on
$ sudo vim /etc/postgresql/10/main/postgresql.conf

# make backup
$ rm -rf /var/lib/postgresql/10/main
$ mkdir -p /var/lib/postgresql/10/main
$ /usr/lib/postgresql/10/bin/pg_basebackup -X stream -D /var/lib/postgresql/10/main -h <master-ip> -U <postgres-user>

# create recovery file
$ sudo vim /var/lib/postgresql/10/main/recovery.conf

# start new standby
$ /usr/lib/postgresql/10/bin/pg_ctl start -D /var/lib/postgresql/10/main
```
