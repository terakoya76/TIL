# 踏み台サーバの中継に使っていた `MySQL Router` がエラーを吐く

`MySQL Router` のopen file limitに引っかかっているのと、`MySQL Server` への接続ができないとのこと。
```bash
$ less /var/log/mysqlrouter/mysqlrouter.log
...

2020-05-15 18:09:46 routing ERROR [7f2fefdd5700] [routing:nssdb] Failed accepting connection: Too many open files
2020-05-15 18:09:46 routing ERROR [7f2fefdd5700] [routing:nssdb] Failed accepting connection: Too many open files
2020-05-15 18:09:46 routing ERROR [7f2fefdd5700] [routing:nssdb] Failed accepting connection: Too many open files
2020-05-15 18:09:46 routing ERROR [7f2fefdd5700] [routing:nssdb] Failed accepting connection: Too many open files
2020-05-15 18:09:46 routing WARNING [7f2ecf60e700] [routing:nssdb] fd=1023 Can't connect to remote MySQL server for client connected to '0.0.0.0:1104'
2020-05-15 18:09:46 routing WARNING [7f2ecf60e700] [routing:nssdb] fd=1023 Can't connect to remote MySQL server for client connected to '0.0.0.0:1104'
2020-05-15 18:09:46 routing WARNING [7f2ecf60e700] [routing:nssdb] fd=1023 Can't connect to remote MySQL server for client connected to '0.0.0.0:1104'
2020-05-15 18:09:46 routing WARNING [7f2ecf60e700] [routing:nssdb] fd=1023 Can't connect to remote MySQL server for client connected to '0.0.0.0:1104'
2020-05-15 18:09:46 routing WARNING [7f2ecf60e700] [routing:nssdb] fd=1023 Can't connect to remote MySQL server for client connected to '0.0.0.0:1104'
2020-05-15 18:09f2ecf60e
```

## `MySQL Server` への接続ができない
Ref: https://dev.mysql.com/doc/mysql-router/8.0/en/mysql-router-conf-options.html#option_mysqlrouter_max_connections

`MySQL Router` のmax connections制限に引っかかっている模様で、512で張り付いていた。
```bash
$ pstree -p mysqlrouter | wc -l
512
```

max connectionsを増やしてやる
```bash
$ ps aux | grep mysql
mysqlro+  4953  0.4  0.9 5240648 36844 ?       Sl   18:52   0:09 /usr/bin/mysqlrouter -c /etc/mysqlrouter/mysqlrouter.conf

$ vim /etc/mysqlrouter/mysqlrouter.conf
[routing:nssdb]
bind_address = 0.0.0.0:1104
destinations = testdb.xxxx.ap-northeast-1.rds.amazonaws.com:3306
mode = read-only
max_connections = 1024  <= これを追加

$ systemctl restart mysqlrouter
```

## mysqlrouter の open file limit
これだけだと `Too many open files` が解決しないので、open file limitも増やす必要がある


```bash
$ lsof -p 4953 | wc -l
1024

$ cat /proc/4953/limits | grep open
1024
```

mysqlrouterはsystemd管理下にいて、systemd-sysv-generatorによりsysv initからservice fileを生成している模様
* https://man7.org/linux/man-pages/man8/systemd-sysv-generator.8.html
```bash
$ systemctl status mysqlrouter
^[[0;1;32m●^[[0m mysqlrouter.service - LSB: Start / Stop MySQL Router
   Loaded: loaded (/etc/init.d/mysqlrouter; bad; vendor preset: enabled)
   Active: ^[[0;1;32mactive (running)^[[0m since Fri 2020-05-15 18:52:34 JST; 38min ago
     Docs: man:systemd-sysv-generator(8)
  Process: 4935 ExecStop=/etc/init.d/mysqlrouter stop (code=exited, status=0/SUCCESS)
  Process: 4942 ExecStart=/etc/init.d/mysqlrouter start (code=exited, status=0/SUCCESS)
   CGroup: /system.slice/mysqlrouter.service
           └─4953 /usr/bin/mysqlrouter -c /etc/mysqlrouter/mysqlrouter.conf

May 15 18:52:34 step systemd[1]: Stopped LSB: Start / Stop MySQL Router.
May 15 18:52:34 step systemd[1]: Starting LSB: Start / Stop MySQL Router...
May 15 18:52:34 step mysqlrouter[4942]:  * Starting MySQL Router
May 15 18:52:34 step mysqlrouter[4942]:    ...done.
May 15 18:52:34 step systemd[1]: Started LSB: Start / Stop MySQL Router.
```

そのためsysv init scriptにlimitを指定すればmysqlrouterに適用してもらえる
```bash
$ vim /etc/init.d/mysqlrouter

...

ulimit -n 2048

...

$ systemctl daemon-reload
$ systemctl restart mysqlrouter

$ ps aux | grep mysql
mysqlro+  5369  0.4  0.9 5240648 36844 ?       Sl   18:52   0:09 /usr/bin/mysqlrouter -c /etc/mysqlrouter/mysqlrouter.conf

$ cat /proc/5369/limits | grep open
2048
```

mysqlrouterが512を超えてconnectionを経由してくれるようになる
```bash
$ pstree -p mysqlrouter|wc -l
542
```
