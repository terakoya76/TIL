# fstab
Like `mount`.
Mount device along with the `/etc/fstab` configuration.

```bash
# mount cmd
$ mount -t ext4 /dev/sda1 /home
```

```fstab
/dev/sda1        /home           ext4    defaults        1 1
```
* 1: device name
* 2: mount point
* 3: FS type
* 4: option
* 5: whether dump FS or not
* 6: whether check by fsck when OS boot, must be 1 for root FS
