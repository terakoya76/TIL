# sysctl

## sysctl.conf
```/etc/sysctl.conf
# Controls IP packet forwarding
net.ipv4.ip_forward = 0

# Disable Checking Packet's source IP
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
```

## reload
if under systemd, use `systemd-sysctl.service`
```bash
$ systemctl restart systemd-sysctl.service
```
