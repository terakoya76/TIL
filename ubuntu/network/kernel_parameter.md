# kernel parameter

## net.core.netdev_max_backlog

NIC Backlogを制御するパラメータ

Ref: https://blog.packagecloud.io/monitoring-tuning-linux-networking-stack-receiving-data/

CPUごとの統計情報
```bash
$ cat /proc/net/softnet_stat
6dcad223 00000000 00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000
6f0e1565 00000000 00000002 00000000 00000000 00000000 00000000 00000000 00000000 00000000
```

* first-column: `sd->processed`
* second-column: `sd->dropped`
  * ここが0以外なら、`net.core.netdev_max_backlog` を増やす


## net.core.somaxconn, net.ipv4.tcp_max_syn_backlog

* `net.core.somaxconn`
  * listen backlog、すなわち `listen()` にbindされたserver socketで、`accept()` を待つESTABLISHED状態のsocket数に関わるカーネルパラメータ。この値は、`listen()` システムコールのパラメータとして設定されるbacklog値のhard limitです
* `net.ipv4.tcp_max_syn_backlog`
  * listen backlog、すなわち `listen()` にbindされたserver socketで、`accept()` を待つSYN_RECEIVED状態のsocket数に関わるカーネルパラメータ。
cf. https://meetup-jp.toast.com/1509

`nstat`で`TcpExtListenOverflows/TcpExtListenDrops`を見ればbacklog溢れがわかる
```bash
$ nstat -z TcpExtListenOverflows
#kernel
TcpExtListenOverflows           0                  0.0
$ nstat -z TcpExtListenDrops
#kernel
TcpExtListenDrops               0                  0.0
```

parameter check
cf. https://qiita.com/sakusrai/items/5e3e9b9475d7ff3ba64e
```bash
$ sysctl net.core.somaxconn
net.core.somaxconn = 128

$ sysctl net.ipv4.tcp_max_syn_backlog
net.ipv4.tcp_max_syn_backlog=128

$ ss -ax | grep -e unicorn
u_str  LISTEN     129    128    /path/to/unicorn.sock 60996                 * 0
u_str  ESTAB      0      0      /path/to/unicorn.sock 1672149               * 0
u_str  ESTAB      0      0      /path/to/unicorn.sock 1666246               * 0
u_str  ESTAB      0      0      /path/to/unicorn.sock 1674255               * 0
u_str  ESTAB      0      0      /path/to/unicorn.sock 1676848               * 0

$ sudo sysctl -w net.core.somaxconn=256
net.core.somaxconn = 256

$ sudo sysctl -w net.ipv4.tcp_max_syn_backlog=256
net.ipv4.tcp_max_syn_backlog = 256

# restart process
$ restart unicorn

$ ss -ax | grep -e unicorn
u_str  LISTEN     0      256    /path/to/unicorn.sock 1698588               * 0
u_str  ESTAB      0      0      /path/to/unicorn.sock 1702421               * 1702420
```


## net.core.rmem_max, net.core.wmem_max, net.ipv4.tcp_rmem, net.ipv4.tcp_wmem

TCPメモリクォータ（カーネル内部では`tcp_memory_allocated`というグローバル変数）は、TCPレイヤの送信処理・受信処理の各所でソフトリミット 、ハードリミットと比較される閾値です。いずれかのリミットを超えていた場合、メモリ割り当てに制限がかかります。
cf. https://tech.pepabo.com/2020/06/26/kernel-dive-tcp-mem/

|名称|数値|リミットの種類|
|-|-|-|
|max|sysctl net.ipv4.tcp_mem[2]|ハードリミット|
|pressure|sysctl net.ipv4.tcp_mem[1]|ソフトリミット|
|min/low|sysctl net.ipv4.tcp_mem[0]||

socket buffer不足ですので、bufferを増やしてやる
cf. https://meetup-jp.toast.com/1505
```bash
$ netstat -s | grep -e 'pruned' -e 'collapsed'
    46 packets pruned from receive queue because of socket buffer overrun
    9107 packets collapsed in receive queue due to low socket buffer

$ sudo sysctl net.core.rmem_default
212992
$ sudo sysctl net.core.rmem_max
212992
$ sudo sysctl net.core.wmem_default
212992
$ sudo sysctl net.core.wmem_max
212992

$ sudo vim /etc/sysctl.conf

# increate upto 300KB
$ sudo sysctl -p
net.core.rmem_max=3145728
net.core.wmem_max=3145728
```


## net.ipv4.fin_timeout

TCP connectionが対向からFINを受けた際にgraceful shutdown periodとしてCLOSE_WAIT stateに移行する。このgraceful shutdown periodの値。
cf. https://meetup-jp.toast.com/1516


## net.ipv4.tcp_max_tw_buckets

TCP connectionが対向からFINを受けた際にgraceful shutdown periodとしてCLOSE_WAIT stateに移行する。このCLOSE_WAITなsocketを保有できるリミット。
リミットを超えると、即座にsocketはdestroyされる。
cf. https://meetup-jp.toast.com/1516

```bash
$ sudo grep "bucket table overflow" /var/log/messages
TCP: time wait bucket table overflow
```


## net.ipv4.tcp_tw_reuse

TCP connectionが対向からFINを受けた際にgraceful shutdown periodとしてCLOSE_WAIT stateに移行する。この際に、CLOSE_WAITなsocketを再利用してconnectionを開くことで、ephemeral port枯渇を防ぐための制御パラメータ
cf. https://meetup-jp.toast.com/1516
cf. https://vincent.bernat.ch/en/blog/2014-tcp-time-wait-state-linux

default: 2

0: 無効
1: 有効
2: lo interfaceもしくはsource or destination IPs is 127.0.0.0/8, ::ffff:127.0.0.0/104 or ::1. のsocketに関してのみ有効
cf. https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=79e9fed460385a3d8ba0b5782e9e74405cb199b1

