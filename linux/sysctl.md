## sysctl

### sysctl.conf
```/etc/sysctl.conf
# Controls IP packet forwarding
net.ipv4.ip_forward = 0
```

### reload
if under systemd, use `systemd-sysctl.service`
```bash
$ systemctl restart systemd-sysctl.service
```
