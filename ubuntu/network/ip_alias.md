# IP alias

label をつけないと ifconfig で表示されない
```bash
$ sudo ip a add 192.168.0.10/24 brd 192.168.0.255 dev eth1 label eth1:0

$ sudo ip a del 192.168.0.10/24 dev eth0
```

```bash
# add private-network route table
$ sudo vim /etc/iproute2/rt_tables
#
# reserved values
#
255     local
254     main
253     default
0       unspec
#
# local
#
#1      inr.ruhep
100     private-network

$ sudo ip r add table private-network 192.168.0.0/24 dev eth1 scope link proto kernel
$ sudo ip r add table private-network default via 192.168.0.1 dev eth1
$ ip r show table private-network

# add routing rule
$ sudo ip rule add from 192.168.0.10 table private-network prio 100
$ ip rule show

$ ip rule
0:      from all lookup local
100:    from 192.168.0.10 lookup private-network
32766:  from all lookup main
32767:  from all lookup default
```

delete routing rule/table
```bash
$ sudo ip rule del pref 10

$ sudo ip r del 192.168.0.0/24 table private-network

$ sudo ip r flush table private-network
```
