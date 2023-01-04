# TCP Keepalive

server 設定
```bash
$ sudo sysctl -a | grep keepalive
net.ipv4.tcp_keepalive_intvl = 75
net.ipv4.tcp_keepalive_probes = 9
net.ipv4.tcp_keepalive_time = 7200
```

service によって独自の keepalive parameter を与える場合もある

例えば nodejs
* https://nodejs.org/api/net.html#socketsetkeepaliveenable-initialdelay
* https://github.com/nodejs/node/pull/32204

default 0、つまり system default (kernel_parameter) が採用されることが多そう。

ss command の timer で initial probe が trigger されることが確認できる。
```bash
$ ss -tiemp | grep 10.0. | grep timer
ESTAB 0      0              172.16.0.2:52946       10.0.3.0:postgresql users:(("node",pid=3889255,fd=19)) timer:(keepalive,2.612ms,0) uid:1107 ino:201072980 sk:2bc cgroup:/user.slice/user-1107.slice/session-8577.scope <->
```
