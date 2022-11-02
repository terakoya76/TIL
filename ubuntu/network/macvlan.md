# macvlan

macvlanは、既に存在する eth0 のような物理的なインターフェースに、新たにMACアドレスを持つ仮想的なインターフェースを作ります。言ってみれば、1つのインターフェースに複数のMACアドレスを割り当てられる機能です。そして、新たに割り当てたMACアドレスを持つ仮想的なインターフェースが作成されます。

LinuxではIPエイリアスと言って、1つのインターフェースに複数のIPアドレスを割り当てることができます。しかし、この機能ではMACアドレスは全て同じになり、DHCPでアドレスを割り当てることはできません。一方、macvlanはMACアドレスを持ちますので、DHCPでアドレスを割り当てることが可能です。

Ref: https://gihyo.jp/admin/serial/01/linux_containers/0006#sec4


```bash
$ sudo ip addr show
(snip)
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 52:54:00:56:3b:3a brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.199/24 brd 192.168.122.255 scope global eth0
    inet6 fe80::5054:ff:fe56:3b3a/64 scope link
       valid_lft forever preferred_lft forever

# create macvlan on eth0
$ sudo ip link add dev macvlan0 link eth0 type macvlan mode bridge
$ sudo ip link show
(snip)
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 52:54:00:56:3b:3a brd ff:ff:ff:ff:ff:ff
3: macvlan0@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
    link/ether 9e:0e:0e:d5:bb:2f brd ff:ff:ff:ff:ff:ff

# set ip address from DHCP
$ sudo dhclient macvlan0
$ sudo ip addr show
  :（略）
3: macvlan0@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN
    link/ether 9e:0e:0e:d5:bb:2f brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.83/24 brd 192.168.122.255 scope global macvlan0
    inet6 fe80::9c0e:eff:fed5:bb2f/64 scope link
       valid_lft forever preferred_lft forever
```

macvlan's mode
* private
  * mode private で設定すると、同じインターフェースに複数の macvlan インターフェースを割り当てた場合、そのインターフェース同士の通信はできません。
  * たとえば、eth0 に接続する macvlan インターフェースとして macvlan0 と macvlan1 インターフェースを private モードで作成した場合、macvlan0 と macvlan1 の間の通信はできません。同じインターフェースに接続する macvlan インターフェースを多数作成して、それぞれをコンテナに割り当てた場合、コンテナ同士の通信ができませんので注意が必要です。
* bridge
  * mode bridge で設定すると、同じインターフェースに割り当てた macvlan インターフェース同士の通信が可能になります。この場合の macvlan インターフェース同士の通信は直接行われ、外部には送出されません。
* vepa
  * mode vepa は mode bridge のように、同じインターフェースに接続した macvlan インターフェース同士の通信が可能なモードです。しかし mode bridge とは違い、macvlan インターフェース間のパケットは、一旦 macvlan インターフェースが接続されるホストのインターフェースが接続している外部のスイッチなどに送出されます。
  * この外部のスイッチが VEPA をサポートしている場合、スイッチに届いた macvlan インターフェース同士のパケットは、再度 macvlan インターフェースを接続したホストのインターフェースに戻されて、目的の macvlan インターフェースに届きます。このような機能を VEPA といいます。つまりコンテナのホストが VEPA 対応のネットワーク機器に接続されている場合に使用するモードです。
* passthru
  * KVM で使われる機能に、macvlan をベースとした macvtap という機能があります。mode passthru はこの macvtap を使った場合の仮想マシンに割り当てたインターフェースの制限を回避するために作られた機能のようです。
