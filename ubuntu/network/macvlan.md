# macvlan

macvlanは、すでに存在するeth0のような物理的なインタフェースに、新たにMACアドレスを持つ仮想的なインタフェースを作ります。言ってみれば、1つのインタフェースに複数のMACアドレスを割り当てられる機能です。そして、新たに割り当てたMACアドレスを持つ仮想的なインタフェースが作成されます。

LinuxではIPエイリアスと言って、1つのインタフェースに複数のIPアドレスを割り当てることができます。しかし、この機能ではMACアドレスはすべて同じになり、DHCPでアドレスを割り当てることはできません。一方、macvlanはMACアドレスを持ちますので、DHCPでアドレスを割り当てることが可能です。

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
  * mode privateで設定すると、同じインタフェースに複数のmacvlanインタフェースを割り当てた場合、そのインタフェースどうしの通信はできません。
  * たとえば、eth0に接続するmacvlanインタフェースとしてmacvlan0とmacvlan1インタフェースをprivateモードで作成した場合、macvlan0とmacvlan1の間の通信はできません。同じインタフェースに接続するmacvlanインタフェースを多数作成して、それぞれをコンテナに割り当てた場合、コンテナどうしの通信ができませんので注意が必要です。
* bridge
  * mode bridgeで設定すると、同じインタフェースに割り当てたmacvlanインタフェースどうしの通信が可能になります。この場合のmacvlanインタフェースどうしの通信は直接行われ、外部には送出されません。
* vepa
  * mode vepaはmode bridgeのように、同じインタフェースに接続したmacvlanインタフェースどうしの通信が可能なモードです。しかしmode bridgeとは違い、macvlanインタフェース間のパケットは、いったんmacvlanインタフェースが接続されるホストのインタフェースが接続している外部のスイッチなどに送出されます。
  * この外部のスイッチがVEPAをサポートしている場合、スイッチに届いたmacvlanインタフェースどうしのパケットは、再度macvlanインタフェースを接続したホストのインタフェースに戻されて、目的のmacvlanインタフェースに届きます。このような機能をVEPAとよいます。つまりコンテナのホストがVEPA対応のネットワーク機器に接続されている場合に使用するモードです。
* passthru
  * KVMで使われる機能に、macvlanをベースとしたmacvtapという機能があります。mode passthruはこのmacvtapを使った場合の仮想マシンに割り当てたインタフェースの制限を回避するために作られた機能のようです。
