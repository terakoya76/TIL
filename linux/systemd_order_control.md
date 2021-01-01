## Summary
mackerel-agent より先に監視対象の unit が shutdown して誤報アラートが飛んでしまうのを防ぐ
つまり監視対象が立ち上がってから mackerel-agent が立ち上がるようにすれば、mackerel-agent が shutdown してから監視対象が shutdown するようになる。

## How to

### Prerequisite
mackerel-agent.service は multi-user.target により起動シーケンスに入る

```bash
$ cat /etc/systemd/system/multi-user.target.wants/mackerel-agent.service
[Unit]
Description=mackerel.io agent
Documentation=https://mackerel.io/
After=network-online.target nss-lookup.target

[Service]
Environment=MACKEREL_PLUGIN_WORKDIR=/var/tmp/mackerel-agent
Environment=ROOT=/var/lib/mackerel-agent
EnvironmentFile=-/etc/default/mackerel-agent
ExecStartPre=/bin/mkdir -m 777 -p $MACKEREL_PLUGIN_WORKDIR
ExecStart=/usr/bin/mackerel-agent supervise --root $ROOT $OTHER_OPTS
ExecStopPost=/bin/sh -c '[ "$AUTO_RETIREMENT" = "" ] || [ "$AUTO_RETIREMENT" = "0" ] && true || /usr/bin/mackerel-agent retire -force --root $ROOT $OTHER_OPTS'
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536
LimitNPROC=65536

[Install]
WantedBy=multi-user.target
```

multi-user.target.wants/* は symlink になっている

```bash
$ ll /etc/systemd/system/multi-user.target.wants/
total 12
drwxr-xr-x  2 root root 4096 Apr  6 07:01 ./
drwxr-xr-x 16 root root 4096 Apr  6 07:03 ../
...
lrwxrwxrwx  1 root root   42 Dec  2 14:58 mackerel-agent.service -> /lib/systemd/system/mackerel-agent.service
...
lrwxrwxrwx  1 root root   33 Dec  2 14:56 nginx.service -> /etc/systemd/system/nginx.service*
...
```

### アプローチ
- mackerel-agent.service に After=nginx.service
- nginx.service に Before=mackerel-agent.service

### 後者の場合

#### before
```bash
$ systemctl list-dependencies nginx.service --before
nginx.service
^[[0;1;32m●^[[0m ├─multi-user.target
^[[0;1;32m●^[[0m │ ├─cloud-final.service
^[[0m●^[[0m │ ├─systemd-update-utmp-runlevel.service
^[[0;1;32m●^[[0m │ ├─cloud-init.target
^[[0;1;32m●^[[0m │ └─graphical.target
^[[0m●^[[0m │   ├─systemd-update-utmp-runlevel.service
^[[0m●^[[0m │   ├─ureadahead-stop.service
^[[0m●^[[0m │   └─ureadahead-stop.timer
^[[0m●^[[0m └─shutdown.target
```

#### order 指定
```bash
$ vim /etc/systemd/system/nginx.service

----
[Unit]
...
Before=mackerel-agent.service

...
----

$ systemctl daemon-reload
```

#### after
```bash
$ systemctl list-dependencies nginx.service --before
nginx.service
^[[0;1;32m●^[[0m ├─mackerel-agent.service
^[[0;1;32m●^[[0m ├─multi-user.target
^[[0;1;32m●^[[0m │ ├─cloud-final.service
^[[0m●^[[0m │ ├─systemd-update-utmp-runlevel.service
^[[0;1;32m●^[[0m │ ├─cloud-init.target
^[[0;1;32m●^[[0m │ └─graphical.target
^[[0m●^[[0m │   ├─systemd-update-utmp-runlevel.service
^[[0m●^[[0m │   ├─ureadahead-stop.service
^[[0m●^[[0m │   └─ureadahead-stop.timer
^[[0m●^[[0m └─shutdown.target
```

### 動作確認

#### systemd の終了シーケンスを起動する
```bash
$ runlevel
N 5

$ init 1

$ runlevel
5 1
```

#### 監視対象よりも先に mackerel-agent が先に shutdown している
```bash
# mackerel - 21:31:10 ~ 21:31:11
$ journalctl -x -u mackerel-agent --no-pager
-- Logs begin at Tue 2020-04-07 20:54:12 JST, end at Tue 2020-04-07 21:31:47 JST. --
Apr 07 21:31:10 ip-x-x-x-x mackerel-agent[1246]: 2020/04/07 21:31:10 INFO <main> Received signal 'terminated', try graceful shutdown up to 30.000000 seconds. If you want force shutdown immediately, send a signal again.
Apr 07 21:31:10 ip-x-x-x-x systemd[1]: Stopping mackerel.io agent...
-- Subject: Unit mackerel-agent.service has begun shutting down
-- Defined-By: systemd
-- Support: http://lists.freedesktop.org/mailman/listinfo/systemd-devel
--
-- Unit mackerel-agent.service has begun shutting down.
Apr 07 21:31:10 ip-x-x-x-x mackerel-agent[1246]: 2020/04/07 21:31:10 INFO <main> Received signal 'terminated' again, force shutdown.
Apr 07 21:31:10 ip-x-x-x-x mackerel-agent[1246]: 2020/04/07 21:31:10 ERROR <pidfile> Failed to remove the pidfile: /var/run/mackerel-agent.pid: remove /var/run/mackerel-agent.pid: no such file or directory
Apr 07 21:31:11 ip-x-x-x-x sh[11551]: 2020/04/07 21:31:11 INFO <main> This host (hostID: 3TWBxAe5WSC) has been retired.
Apr 07 21:31:11 ip-x-x-x-x systemd[1]: Stopped mackerel.io agent.
-- Subject: Unit mackerel-agent.service has finished shutting down
-- Defined-By: systemd
-- Support: http://lists.freedesktop.org/mailman/listinfo/systemd-devel
--
-- Unit mackerel-agent.service has finished shutting down.

# nginx - 21:31:11 ~ 21:31:28
$ journalctl -x -u nginx --no-pager
-- Logs begin at Tue 2020-04-07 20:54:12 JST, end at Tue 2020-04-07 21:31:35 JST. --
Apr 07 21:31:11 ip-x-x-x-x systemd[1]: Stopping starts the nginx web server...
-- Subject: Unit nginx.service has begun shutting down
-- Defined-By: systemd
-- Support: http://lists.freedesktop.org/mailman/listinfo/systemd-devel
--
-- Unit nginx.service has begun shutting down.
Apr 07 21:31:11 ip-x-x-x-x systemd[1]: Stopped starts the nginx web server.
-- Subject: Unit nginx.service has finished shutting down
-- Defined-By: systemd
-- Suppodirectrt: http://lists.freedesktop.org/mailman/listinfo/systemd-devel
--
-- Unit nginx.service has finished shutting down.
Apr 07 21:31:28 ip-x-x-x-x systemd[1]: Stopped starts the nginx web server.
-- Subject: Unit nginx.service has finished shutting down
-- Defined-By: systemd
-- Support: http://lists.freedesktop.org/mailman/listinfo/systemd-devel
--
-- Unit nginx.service has finished shutting down.
```
