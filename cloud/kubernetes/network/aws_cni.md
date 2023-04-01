# How aws-cni works

## kube-system
```bash
$ k -n kube-system get po -A -o wide
aws-node-2xkdp                                               1/1     Running            0          17h     10.1.12.251   ip-10-1-12-251.ap-northeast-1.compute.internal   <none>           <none>
aws-node-87x2n                                               1/1     Running            0          37d     10.1.10.203   ip-10-1-10-203.ap-northeast-1.compute.internal   <none>           <none>
coredns-6c6685d675-2pjp4                                     1/1     Running            0          2d13h   10.1.9.170    ip-10-1-10-203.ap-northeast-1.compute.internal   <none>           <none>
coredns-6c6685d675-v8jrg                                     1/1     Running            0          35d     10.1.9.105    ip-10-1-10-203.ap-northeast-1.compute.internal   <none>           <none>

$ k -n kube-system exec -it aws-node-2xkdp -- /bin/sh
```

## iptables
```bash
$ iptables -L -nv
Chain INPUT (policy ACCEPT 10 packets, 635 bytes)
 pkts bytes target     prot opt in     out     source               destination
33364 2099K KUBE-SERVICES  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes service portals */
33364 2099K KUBE-EXTERNAL-SERVICES  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes externally-visible service portals */
1355K 1483M KUBE-FIREWALL  all  --  *      *       0.0.0.0/0            0.0.0.0/0

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
1334K  798M KUBE-FORWARD  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes forwarding rules */
 144K   14M KUBE-SERVICES  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes service portals */
1333K  798M DOCKER-USER  all  --  *      *       0.0.0.0/0            0.0.0.0/0

Chain OUTPUT (policy ACCEPT 11 packets, 630 bytes)
 pkts bytes target     prot opt in     out     source               destination
 123K 9782K KUBE-SERVICES  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes service portals */
1318K 1303M KUBE-FIREWALL  all  --  *      *       0.0.0.0/0            0.0.0.0/0

Chain DOCKER (0 references)
 pkts bytes target     prot opt in     out     source               destination

Chain DOCKER-ISOLATION-STAGE-1 (0 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0

Chain DOCKER-ISOLATION-STAGE-2 (0 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0

Chain DOCKER-USER (1 references)
 pkts bytes target     prot opt in     out     source               destination
1333K  798M RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0

Chain KUBE-EXTERNAL-SERVICES (1 references)
 pkts bytes target     prot opt in     out     source               destination

Chain KUBE-FIREWALL (2 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes firewall for dropping marked packets */ mark match 0x8000/0x8000

Chain KUBE-FORWARD (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes forwarding rules */ mark match 0x4000/0x4000

Chain KUBE-SERVICES (3 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 REJECT     tcp  --  in
```

iptables -L [-t filter]
iptables -L -t nat
iptables -L -t mangle

## ip rule
```bash
$ ip rule
0:	from all lookup local
512:	from all to 10.1.12.97 lookup main
512:	from all to 10.1.15.210 lookup main
512:	from all to 10.1.12.216 lookup main
1024:	from all fwmark 0x80/0x80 lookup main
32766:	from all lookup main
32767:	from all lookup default

$ ip rule del from all to 10.1.12.216 lookup main
$ ip rule add from all to 10.1.12.216 lookup main
```

## ip route
```bash
$ ip route show table main
```

## ipamd log
```bash
$ cat /host/var/log/aws-routed-eni/ipamd.log.2020-04-03-06 | grep 10.1.9.105
```

