# IP Routing based on destination port

```bash
sudo iptables -A OUTPUT -t mangle -p tcp --destination-port 2380 -j MARK --set-mark 1

table=etcd
sudo ip rule add fwmark 1 table ${table}
sudo ip route add default via $(tailscale ip -4) dev tailscale0 table ${table}
```
