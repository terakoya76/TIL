## sar

### Summary
```bash
$ sar [opt ...]
```

### CPU
* `-q` run queue statistics

### Memory
* `-B` page statistics
* `-H` huge page statistics
* `-r` memory utilization
* `-R` memory statistics
* `-g` page out and frees memory statistics
* `-S` swap space statistics
* `-W` swapping statistics

### FS
* `-v` system table statistics

### Disk
* `-d` disk statistics

### Network
* `-n DEV` network interface statistics
* `-n EDEV` network interface errors
* `-n IP,IP6` IPv4 and IPv6 datagram statistics
* `-n EIP,EIP6` IPv4 and IPv6 error statistics
* `-n ICMP,ICMP6` ICMP IPv4 and IPv6 statistics
* `-n EICMP,EICMP6` ICMP IPv4 and IPv6 error statistics
* `-n TCP` TCP statistics
* `-n ETCP` TCP error statistics
* `-n SOCK,SOCK6` IPv4 and IPv6 socket usage
