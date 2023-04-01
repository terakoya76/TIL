# dnsmasq

## Migrate dnsmasq from systemd-resolved

systemd-resolvedをやめる
```bash
$ sudo vim /etc/systemd/resolved.conf

[Resolve]
DNSStubListener=no

$ sudo systemctl restart systemd-resolved
```

DHCPで降ってくるDNSサーバの情報を反映させるためNetworkManagerの設定をする
```bash
$ sudo vim /etc/NetworkManager/NetworkManager.conf

[main]
dns=default

$ ls -lah /etc/resolv.conf
Permissions Size User Date Modified Name
lrwxrwxrwx    39 root  8 11月  2020 /etc/resolv.conf -> ../run/systemd/resolve/stub-resolv.conf

# /etc/resolv.conf が systemd-resolved にリンクされていると、そちらが使われてしまうので解除
$ sudo unlink /etc/resolv.conf

$ sudo systemctl restart NetworkManager
```

## Client-Side DNS Round Robin

```bash
# add /etc/hosts
10.0.7.10 hoge
10.0.7.11 hoge

# add /etc/resolv.conf
nameserver 127.0.0.1 # dnsmasq に先に聞きに行かせる
nameserver 192.168.11.1

$ sudo systemctl restart dnsmasq

$ nslookup hoge
Server:         127.0.0.1
Address:        127.0.0.1#53

Name:   hoge
Address: 10.0.7.10
Name:   hoge
Address: 10.0.7.11

$ nslookup hoge
Server:         127.0.0.1
Address:        127.0.0.1#53

Name:   hoge
Address: 10.0.7.11
Name:   hoge
Address: 10.0.7.10
```

