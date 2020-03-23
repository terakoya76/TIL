Ref: https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/recognize-expanded-volume-linux.html

```bash
$ sudo lsblk
NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda    202:0    0  20G  0 disk
└─xvda1 202:1    0  10G  0 part /

$ sudo growpart /dev/xvda 1
CHANGED: partition=1 start=2048 old: size=20969439 end=20971487 new: size=41940959,end=41943007

$ sudo lsblk
NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda    202:0    0  20G  0 disk
└─xvda1 202:1    0  20G  0 part /

$ sudo resize2fs /dev/xvda1
resize2fs 1.42.13 (17-May-2015)
Filesystem at /dev/xvda1 is mounted on /; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 2
The filesystem on /dev/xvda1 is now 5242619 (4k) blocks long.

$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1       20G  8.5G   11G  44% /
```
