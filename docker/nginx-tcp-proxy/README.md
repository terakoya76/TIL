# nginx-tcp-proxy
setup DNS Round Robin
```bash
# setup dnsmasq
...

$ vim /etc/hosts
10.0.7.11 tcpproxy
10.0.7.12 tcpproxy

$ vim /etc/resolv.conf
nameserver 127.0.0.1 # dnsmasq に先に聞きに行かせる
nameserver 192.168.11.1

$ sudo systemctl restart dnsmasq
```

setup docker network and nginx
```bash
$ make net.run

$ make nginx.build
$ make nginx.run

$ curl tcpproxy:12345/status
$ curl tcpproxy:12345/status
$ make nginx.log

$ make nginx.rm
$ make net.rm
```
