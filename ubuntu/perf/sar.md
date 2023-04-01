# sar

# Summary
```bash
$ sar [opt ...]
```

## CPU
* `-q` run queue stats

## Memory
* `-B` page stats
* `-H` huge page stats
* `-r` memory utilization
* `-R` memory stats
* `-g` page out and frees memory stats
* `-S` swap space stats
* `-W` swapping stats

## FileSystem
* `-v` file system stats

## Disk
* `-d` Disk stats

## Network
* `-n DEV` network interface stats
* `-n EDEV` network interface Errors
* `-n IP,IP6` IPv4 and IPv6 Datagram stats
* `-n EIP,EIP6` IPv4 and IPv6 Error stats
* `-n ICMP,ICMP6` ICMP IPv4 and IPv6 stats
* `-n EICMP,EICMP6` ICMP IPv4 and IPv6 Error stats
* `-n TCP` TCP stats
* `-n ETCP` TCP Error stats
* `-n SOCK,SOCK6` IPv4 and IPv6 socket usage
