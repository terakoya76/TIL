# veth setup

Ref: https://gihyo.jp/admin/serial/01/linux_containers/0006

```bash
# create veth pair
$ sudo ip link add name veth0-host type veth peer name veth0-ct

$ sudo ip link show
(snip)
3: veth0-ct: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether be:82:25:d8:94:30 brd ff:ff:ff:ff:ff:ff
4: veth0-host: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 12:e5:61:4b:42:ba brd ff:ff:ff:ff:ff:ff

# set ip address to veth
$ sudo ip addr add 10.10.10.10/24 dev veth0-host
$ sudo ip addr add 10.10.10.11/24 dev veth0-ct

# up veth
$ sudo ip link set up veth0-host
$ sudo ip link set up veth0-ct

$ sudo ip addr show
(snip)
3: veth0-ct: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether be:82:25:d8:94:30 brd ff:ff:ff:ff:ff:ff
    inet 10.10.10.11/24 scope global veth0-ct
       valid_lft forever preferred_lft forever
    inet6 fe80::bc82:25ff:fed8:9430/64 scope link
       valid_lft forever preferred_lft forever
4: veth0-host: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 12:e5:61:4b:42:ba brd ff:ff:ff:ff:ff:ff
    inet 10.10.10.10/24 scope global veth0-host
       valid_lft forever preferred_lft forever
    inet6 fe80::10e5:61ff:fe4b:42ba/64 scope link
       valid_lft forever preferred_lft forever

# ping Unreachable
$ ping -I veth0-host 10.10.10.11
PING 10.10.10.11 (10.10.10.11) from 10.10.10.11 veth0-host: 56(84) bytes of data.
From 10.10.10.10 icmp_seq=1 Destination Host Unreachable
From 10.10.10.10 icmp_seq=2 Destination Host Unreachable
From 10.10.10.10 icmp_seq=3 Destination Host Unreachable
```

veth は異なる ns 間でないと疎通できない。
```bash
# add ns
$ sudo ip netns add netns01
$ sudo ip netns list
netns01

# move veth0-ct to the other ns
$ sudo ip link set veth0-ct netns netns01
$ sudo ip link show | grep veth0
4: veth0-host: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN qlen 1000
$ sudo ip netns exec netns01 ip link show
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
3: veth0-ct: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether be:82:25:d8:94:30 brd ff:ff:ff:ff:ff:ff

# set ip address to moved veth
$ sudo ip netns exec netns01 ip addr add 10.10.10.11/24 dev veth0-ct

# up moved veth
$ sudo ip netns exec netns01 ip link set veth0-ct up

$ sudo ip netns exec netns01 ip addr show
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
3: veth0-ct: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether be:82:25:d8:94:30 brd ff:ff:ff:ff:ff:ff
    inet 10.10.10.11/24 scope global veth0-ct
       valid_lft forever preferred_lft forever
    inet6 fe80::bc82:25ff:fed8:9430/64 scope link
       valid_lft forever preferred_lft forever

# ping reachable
$ ping -I veth0-host 10.10.10.11
PING 10.10.10.11 (10.10.10.11) from 10.10.10.10 veth0-host: 56(84) bytes of data.
64 bytes from 10.10.10.11: icmp_req=1 ttl=64 time=0.134 ms
64 bytes from 10.10.10.11: icmp_req=2 ttl=64 time=0.098 ms
64 bytes from 10.10.10.11: icmp_req=3 ttl=64 time=0.097 ms

$ sudo ip netns exec netns01 ping 10.10.10.10
PING 10.10.10.10 (10.10.10.10) 56(84) bytes of data.
64 bytes from 10.10.10.10: icmp_req=1 ttl=64 time=0.069 ms
64 bytes from 10.10.10.10: icmp_req=2 ttl=64 time=0.068 ms
64 bytes from 10.10.10.10: icmp_req=3 ttl=64 time=0.075 ms
```
