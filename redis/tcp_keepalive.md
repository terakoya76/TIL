# TCP-Keepalive

int型となるように `server.tcpkeepalive` に渡される
* https://github.com/redis/redis/blob/a43b6922d1e37d60acf63484b7057299c9bf584d/src/config.c#L2828

conn を確立したあと、`server.tcpkeepalive` が1以上であれば `anetKeepAlive()` を実行
* https://github.com/redis/redis/blob/aa856b39f2ca65dbcc0eaae2d2c52f7a35291bbf/src/networking.c#L129-L130
* https://github.com/redis/redis/blob/496375fc36134c72461e6fb97f314be3adfd8b68/src/connection.c#L425

`anetKeepAlive()` では、`setsockopt` システムコールにてソケットオプション `SO_KEEPALIVE` を有効化
* https://github.com/redis/redis/blob/0fb1aa0645fd1e31d12c8d57d4326ded0aa4d555/src/anet.c#L128

## SO_KEEPALIVE
* `net.ipv4.tcp_keepalive_time: SO_KEEPALIVE` が有効のとき、接続が idol になってから tcp_keepalive_time 秒（デフォルト7200秒）経過後に keep-alive プローブを送信する
* `net.ipv4.tcp_keepalive_probes:` keep-alive プローブの再送回数（デフォルト9回）。この回数試行しても応答がなければ切断と扱う
`net.ipv4.tcp_keepalive_intvl:` tcp_keepalive_probes に対応する、keep-alive プローブの再送の間隔（秒、デフォルト75秒）

Redis は Linux の上記パラメータの値を用いず redis-server の `tcp-keepalive` の値に依存した keep-alive を行う
* https://github.com/redis/redis/blob/0fb1aa0645fd1e31d12c8d57d4326ded0aa4d555/src/anet.c#L134-L162

1. 接続が idol になってから `tcp-keepalive` 秒経過後に keep-alive プローブを送信
2. `tcpkeepalive` / 3秒ごとに3回keep-aliveプローブを再送
3. それでも応答がなければ切断と扱う
