## MONyog Disk Space Shortage

EBS が2つ attach されており、`/data` 下のスペースが減っていることがわかる
```bash
$ lsblk
NAME                MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda                202:0    0  16G  0 disk
└─xvda1             202:1    0  16G  0 part /
xvdb                202:16   0  80G  0 disk
└─data-lvol0 (dm-0) 252:0    0  80G  0 lvm  /data

$ df -h
Filesystem              Size  Used Avail Use% Mounted on
udev                    3.9G   12K  3.9G   1% /dev
tmpfs                   799M  392K  799M   1% /run
/dev/xvda1               16G  2.3G   13G  16% /
none                    4.0K     0  4.0K   0% /sys/fs/cgroup
none                    5.0M     0  5.0M   0% /run/lock
none                    3.9G     0  3.9G   0% /run/shm
none                    100M     0  100M   0% /run/user
/dev/mapper/data-lvol0   79G   62G   13G  83% /data
```

MONyog の実体は `/data` にある
```bash
$ ll /opt/MONyog
lrwxrwxrwx 1 root root 13 Feb 26 20:31 /opt/MONyog -> /data/MONyog//

# 結果は作業後の後付けなのでもっと大きい
$ /data/MONyog# du -m
530     ./bin
12      ./res
1       ./data/0003/realtimedata
44      ./data/0003
5281    ./data/0001/realtimedata
10999   ./data/0001
1       ./data/0000
1       ./data/0002/realtimedata
1227    ./data/0002
12270   ./data
12824   .
```

realtimedata が膨れていることがわかる
```bash
$ ls -lh /data/MONyog/data/0001/realtimedata/
total 51G
-rw------- 1 root root 2.6G Apr 10  2017 rt_Apr03.data
-rw------- 1 root root  32K Apr 14  2017 rt_Apr03.data-shm
-rw------- 1 root root    0 Apr 14  2017 rt_Apr03.data-wal
-rw------- 1 root root  14G Dec 27  2019 rt_Dec24.data
-rw------- 1 root root  32K Jan 20  2020 rt_Dec24.data-shm
-rw------- 1 root root    0 Jan 20  2020 rt_Dec24.data-wal
-rw------- 1 root root 8.1G Mar  1 18:52 rt_Feb27.data
-rw------- 1 root root  32K Mar  6 13:24 rt_Feb27.data-shm
-rw------- 1 root root    0 Mar  6 13:24 rt_Feb27.data-wal
-rw------- 1 root root 4.8G Jul  5 17:46 rt_Jul02.data
-rw------- 1 root root  32K Jul  8 12:55 rt_Jul02.data-shm
-rw------- 1 root root    0 Jul  8 12:55 rt_Jul02.data-wal
-rw------- 1 root root 6.3G Aug  3 11:31 rt_Jul31.data
-rw------- 1 root root  32K Aug 11 10:57 rt_Jul31.data-shm
-rw------- 1 root root    0 Aug 11 10:57 rt_Jul31.data-wal
-rw------- 1 root root  11G Dec  3  2019 rt_Nov12.data
-rw------- 1 root root  64K Dec  3  2019 rt_Nov12.data-shm
-rw------- 1 root root  17M Dec  3  2019 rt_Nov12.data-wal
-rw------- 1 root root 4.7G Aug 19 15:15 tmp_rt_1597714225.data
-rw------- 1 root root  32K Aug 19 15:15 tmp_rt_1597714225.data-shm
-rw------- 1 root root  14M Aug 19 15:15 tmp_rt_1597714225.data-wal
```

MONyog data の実体は sqlite database
Ref: http://wiki.idera.com/display/SQLDMYSQL/Real-Time+data

```bash
$ ls /data/MONyog/data/0000
events_overview.data  sniffer_overview.data

$ sqlite3 /data/MONyog/data/0000/events_overview.data
SQLite version 3.8.2 2013-12-06 14:53:30
Enter ".help" for instructions
Enter SQL statements terminated with a ";"
sqlite> .schema
CREATE TABLE [alert_details] (                                        server_id VARCHAR(5) PRIMARY KEY DEFAULT '',                                         critical_count INTEGER DEFAULT 0,                                        warning_count INTEGER DEFAULT 0,                                        is_available BOOL);
CREATE TABLE [schema_version] (                                [schema_desc] TEXT,                                [schema_major_version] TEXT,                                [schema_minor_version] TEXT,                                PRIMARY KEY ([schema_major_version], [schema_minor_version]));

sqlite> select * from schema_version;
7.01|7|01
```

realtime analytics は日毎に database を分けている模様
MONyog UI から persited session を Load するときには on-demand で DB につないでるのだろう
不要そうな database を削除して disk を空ければ良い
```bash
$ rm /data/MONyog/data/0001/realtimedata/rt_*
$ ls -lh /data/MONyog/data/0001/realtimedata/
total 5.0G
-rw------- 1 root root 5.0G Aug 19 16:42 tmp_rt_1597714225.data
-rw------- 1 root root  32K Aug 19 16:42 tmp_rt_1597714225.data-shm
-rw------- 1 root root  14M Aug 19 16:42 tmp_rt_1597714225.data-wal

$ df -h
Filesystem              Size  Used Avail Use% Mounted on
udev                    3.9G   12K  3.9G   1% /dev
tmpfs                   799M  400K  799M   1% /run
/dev/xvda1               16G  2.3G   13G  16% /
none                    4.0K     0  4.0K   0% /sys/fs/cgroup
none                    5.0M     0  5.0M   0% /run/lock
none                    3.9G     0  3.9G   0% /run/shm
none                    100M     0  100M   0% /run/user
/dev/mapper/data-lvol0   79G   13G   63G  17% /data
```
