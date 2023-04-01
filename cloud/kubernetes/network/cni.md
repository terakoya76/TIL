# cni-tmp

setup
```bash
$ aws ssm start-session --target i-0cbdbe933a9cf960f
$ sudo yum install iproute
```

host interface
```bash
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
# bridge
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc mq state UP group default qlen 1000
    link/ether 06:54:01:71:9d:74 brd ff:ff:ff:ff:ff:ff
    inet 10.0.28.77/21 brd 10.0.31.255 scope global dynamic eth0
       valid_lft 2792sec preferred_lft 2792sec
    inet6 fe80::454:1ff:fe71:9d74/64 scope link
       valid_lft forever preferred_lft forever
# 同一 asg instance eni
3: enia48b04d4c1d: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UP group default
    link/ether 56:04:85:0d:e0:27 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet6 fe80::5404:85ff:fe0d:e027/64 scope link
       valid_lft forever preferred_lft forever
# 同一 asg instance eni
4: eni77c2a4afbb3@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UP group default
    link/ether 72:6e:8d:72:22:72 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet6 fe80::706e:8dff:fe72:2272/64 scope link
       valid_lft forever preferred_lft forever
# 同一 asg instance eni
5: enib92ae06b5ec@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UP group default
    link/ether 2e:0e:11:41:b0:30 brd ff:ff:ff:ff:ff:ff link-netnsid 2
    inet6 fe80::2c0e:11ff:fe41:b030/64 scope link
       valid_lft forever preferred_lft forever
1053: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc mq state UP group default qlen 1000
    link/ether 06:0b:06:83:7b:16 brd ff:ff:ff:ff:ff:ff
    inet 10.0.28.163/21 brd 10.0.31.255 scope global eth2
       valid_lft forever preferred_lft forever
    inet6 fe80::40b:6ff:fe83:7b16/64 scope link
       valid_lft forever preferred_lft forever
1662: enia5e520181dc@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UP group default
    link/ether ea:8e:dd:dd:b8:bd brd ff:ff:ff:ff:ff:ff link-netnsid 7
    inet6 fe80::e88e:ddff:fedd:b8bd/64 scope link
       valid_lft forever preferred_lft forever
# bridge
1665: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 06:29:08:a8:2c:00 brd ff:ff:ff:ff:ff:ff
b8b

$ ip l
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 06:54:01:71:9d:74 brd ff:ff:ff:ff:ff:ff
3: enia48b04d4c1d: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UP mode DEFAULT group default
    link/ether 56:04:85:0d:e0:27 brd ff:ff:ff:ff:ff:ff link-netnsid 0
4: eni77c2a4afbb3@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UP mode DEFAULT group default
    link/ether 72:6e:8d:72:22:72 brd ff:ff:ff:ff:ff:ff link-netnsid 1
5: enib92ae06b5ec@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UP mode DEFAULT group default
    link/ether 2e:0e:11:41:b0:30 brd ff:ff:ff:ff:ff:ff link-netnsid 2
1665: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 06:29:08:a8:2c:00 brd ff:ff:ff:ff:ff:ff

$ ip -d l show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 06:54:01:71:9d:74 brd ff:ff:ff:ff:ff:ff promiscuity 0 addrgenmode eui64 numtxqueues 2 numrxqueues 2 gso_max_size 65536 gso_max_segs 65535
$ ip -d l show eth1
1665: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 06:29:08:a8:2c:00 brd ff:ff:ff:ff:ff:ff promiscuity 0 addrgenmode eui64 numtxqueues 2 numrxqueues 2 gso_max_size 65536 gso_max_segs 65535
$ ip -d l show enia48b04d4c1d
3: enia48b04d4c1d: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UP mode DEFAULT group default
    link/ether 56:04:85:0d:e0:27 brd ff:ff:ff:ff:ff:ff link-netnsid 0 promiscuity 0
    veth addrgenmode eui64 numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535
$ ip -d l show eni77c2a4afbb3
4: eni77c2a4afbb3@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UP mode DEFAULT group default
    link/ether 72:6e:8d:72:22:72 brd ff:ff:ff:ff:ff:ff link-netnsid 1 promiscuity 0
    veth addrgenmode eui64 numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535
$ ip -d l show enib92ae06b5ec
5: enib92ae06b5ec@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue state UP mode DEFAULT group default
    link/ether 2e:0e:11:41:b0:30 brd ff:ff:ff:ff:ff:ff link-netnsid 2 promiscuity 0
    veth addrgenmode eui64 numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535

# pod cluster ip ?
$ ip r
default via 10.0.24.1 dev eth0
10.0.24.0/21 dev eth0 proto kernel scope link src 10.0.28.77 <= aws-node pod IP
10.0.24.150 dev enib92ae06b5ec scope link
10.0.26.102 dev enia48b04d4c1d scope link
10.0.26.188 dev eni77c2a4afbb3 scope link
169.254.169.254 dev eth0


```
