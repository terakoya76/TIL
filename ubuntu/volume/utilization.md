# Storage Utilization

```bash
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
udev            216M     0  216M   0% /dev
tmpfs            48M  1.3M   47M   3% /run
/dev/vda2        30G   24G  4.5G  85% /
tmpfs           237M     0  237M   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           237M     0  237M   0% /sys/fs/cgroup
/dev/loop2       68M   68M     0 100% /snap/lxd/22526
/dev/loop8       56M   56M     0 100% /snap/core18/2344
/dev/loop0       68M   68M     0 100% /snap/lxd/22753
/dev/loop9       56M   56M     0 100% /snap/core18/2409
/dev/loop1       45M   45M     0 100% /snap/snapd/15904
/dev/loop10      62M   62M     0 100% /snap/core20/1494
/dev/loop5       62M   62M     0 100% /snap/core20/1518
/dev/loop7       47M   47M     0 100% /snap/snapd/16010
tmpfs            48M     0   48M   0% /run/user/1103
```

```bash
$ sudo du -h -d 1 /
```
