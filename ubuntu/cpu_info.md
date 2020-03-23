# CPU info

## CPU
```bash
$ sudo lshw -class processor

# or cpuinfo
## physical
$ sudo cat /proc/cpuinfo | grep 'cpu cores' | uniq

## logical
$ sudo cat /proc/cpuinfo | grep 'processor' | uniq
```

## GPU

lspicからgrepで探す
```bash
$ lspci | grep -i nvidia
```
