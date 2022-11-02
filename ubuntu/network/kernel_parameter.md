# kernel parameter

## net.core.netdev_max_backlog

NIC Backlog を制御するパラメーター

Ref: https://blog.packagecloud.io/monitoring-tuning-linux-networking-stack-receiving-data/

CPU ごとの統計情報
```bash
$ cat /proc/net/softnet_stat
6dcad223 00000000 00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000
6f0e1565 00000000 00000002 00000000 00000000 00000000 00000000 00000000 00000000 00000000
```

first-column: sd->processed
second-column: sd->dropped
* ここが0以外なら、`net.core.netdev_max_backlog` を増やす


## net.core.somaxconn, net.ipv4.tcp_max_syn_backlog

net.core.somaxconn: listen backlog、すなわち `listen()` に bind された server socket で、`accept()` を待つ ESTABLISHED 状態の socket 数に関わるカーネルパラメータ。この値は、`listen()` システムコールのパラメータとして設定される backlog 値の hard limit です。
net.ipv4.tcp_max_syn_backlog: listen backlog、すなわち `listen()` に bind された server socket で、`accept()` を待つ SYN_RECEIVED 状態の socket 数に関わるカーネルパラメータ。
cf. https://meetup-jp.toast.com/1509

nstat で TcpExtListenOverflows/TcpExtListenDrops を見れば backlog 溢れがわかる
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

TCP メモリクォータ (カーネル内部では tcp_memory_allocated というグローバル変数) は、TCP レイヤーの送信処理・受信処理の各所で ソフトリミット 、ハードリミット と比較される閾値です。いずれかのリミットを超えていた場合にメモリ割り当てに制限がかかります。
cf. https://tech.pepabo.com/2020/06/26/kernel-dive-tcp-mem/

|名称|数値|リミットの種類|
|-|-|-|
|max|sysctl net.ipv4.tcp_mem[2]|ハードリミット|
|pressure|sysctl net.ipv4.tcp_mem[1]|ソフトリミット|
|min/low|sysctl net.ipv4.tcp_mem[0]||

socket buffer 不足なので、buffer を増やしてやる
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

TCP connection が対向から FIN を受けた際に graceful shutdown period として CLOSE_WAIT state に移行する。この graceful shutdown period の値。
cf. https://meetup-jp.toast.com/1516


## net.ipv4.tcp_max_tw_buckets

TCP connection が対向から FIN を受けた際に graceful shutdown period として CLOSE_WAIT state に移行する。この CLOSE_WAIT な socket を保有できるリミット。
リミットを超えると、即座に socket は destroy される。
cf. https://meetup-jp.toast.com/1516

```bash
$ sudo grep "bucket table overflow" /var/log/messages
TCP: time wait bucket table overflow
```


## net.ipv4.tcp_tw_reuse

TCP connection が対向から FIN を受けた際に graceful shutdown period として CLOSE_WAIT state に移行する。この際に、CLOSE_WAIT な socket を再利用して connection を開くことで、ephemeral port 枯渇を防ぐための制御パラメータ
cf. https://meetup-jp.toast.com/1516
cf. https://vincent.bernat.ch/en/blog/2014-tcp-time-wait-state-linux

default: 2

0: 無効
1: 有効
2: lo interface もしくは source or destination IPs is 127.0.0.0/8, ::ffff:127.0.0.0/104 or ::1. の socket に関してのみ有効
cf. https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=79e9fed460385a3d8ba0b5782e9e74405cb199b1

