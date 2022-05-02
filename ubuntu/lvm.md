# lvm
## Mount FS from the attached volumes
volume `xvdf, xvdg, xvdh` が attach されていることを確認
```bash
$ lsblk
NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda    202:0    0   8G  0 disk
└─xvda1 202:1    0   8G  0 part /
xvdf    202:80   0   8G  0 disk
xvdg    202:96   0   8G  0 disk
xvdh    202:112  0   8G  0 disk
```

```bash
$ sudo yum install -y lvm2 parted

# create partition
$ sudo parted /dev/xvdf
GNU Parted 2.1
Using /dev/xvdf
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) mklabel msdos
(parted) mkpart primary
File system type?  [ext2]? ext4
Start? 1
End? -1
(parted) set 1 lvm on
(parted) p
Model: Xen Virtual Block Device (xvd)
Disk /dev/xvdf: 8590MB
Sector size (logical/physical): 512B/512B
Partition Table: msdos

Number  Start   End     Size    Type     File system  Flags
 1      1049kB  8589MB  8588MB  primary               lvm
(parted) quit
Information: You may need to update /etc/fstab.

$ lsblk
NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda    202:0    0   8G  0 disk
└─xvda1 202:1    0   8G  0 part /
xvdf    202:80   0   8G  0 disk
└─xvdf1 202:81   0   8G  0 part
xvdg    202:96   0   8G  0 disk
└─xvdg1 202:97   0   8G  0 part
xvdh    202:112  0   8G  0 disk
└─xvdh1 202:113  0   8G  0 part

# create physical volume
$ sudo pvcreate /dev/xvdf1 /dev/xvdg1 /dev/xvdh1
  Physical volume "/dev/xvdf1" successfully created
  Physical volume "/dev/xvdg1" successfully created
  Physical volume "/dev/xvdh1" successfully created

$ sudo pvdisplay
  "/dev/xvdf1" is a new physical volume of "8.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/xvdf1
  VG Name
  PV Size               8.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               c027jU-HJnr-juMY-KqQI-7Xl7-xQOA-7vEA0P

  "/dev/xvdg1" is a new physical volume of "8.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/xvdg1
  VG Name
  PV Size               8.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               viFf3l-8Ssr-wJij-Phc2-dTtm-IqkL-Btt3am

  "/dev/xvdh1" is a new physical volume of "8.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/xvdh1
  VG Name
  PV Size               8.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               t3i9He-ShC9-40yg-F8J

# create volume group
$ sudo vgcreate lvg-extvol /dev/xv{df1,dg1,dh1}
  Volume group "lvg-extvol" successfully created

$ sudo vgdisplay
  --- Volume group ---
  VG Name               lvg-extvol
  System ID
  Format                lvm2
  Metadata Areas        3
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                3
  Act PV                3
  VG Size               23.99 GiB
  PE Size               4.00 MiB
  Total PE              6141
  Alloc PE / Size       0 / 0
  Free  PE / Size       6141 / 23.99 GiB
  VG UUID               vfZYLD-jxzl-awqq-NeXS-7HeK-tunE-aO3zYG

$ sudo vgscan
  Reading all physical volumes.  This may take a while...
  Found volume group "lvg-extvol" using metadata type lvm2

# create logical volume
$ sudo lvcreate -n extvol -l 100%FREE lvg-extvol
  Logical volume "extvol" created.

$ sudo lvdisplay
  --- Logical volume ---
  LV Path                /dev/lvg-extvol/extvol
  LV Name                extvol
  VG Name                lvg-extvol
  LV UUID                c0AUWG-xkZC-4Th0-5vRT-pjb4-2mWW-YcTbXM
  LV Write Access        read/write
  LV Creation host, time ip-172-31-14-198, 2021-01-07 16:42:32 +0000
  LV Status              available
  # open                 0
  LV Size                23.99 GiB
  Current LE             6141
  Segments               3
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

$ sudo lvscan
  ACTIVE            '/dev/lvg-extvol/extvol' [23.99 GiB] inherit

# create file system
$ sudo mkfs.ext4 /dev/lvg-extvol/extvol
mke2fs 1.41.12 (17-May-2010)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
1572864 inodes, 6288384 blocks
314419 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=4294967296
192 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
	4096000

Writing inode tables: done
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done

This filesystem will be automatically checked every 34 mounts or
180 days, whichever comes first.  Use tune2fs -c or -i to override.

# mount file system
$ sudo mkdir /mnt/extvol
$ sudo mount /dev/lvg-extvol/extvol /mnt/extvol

# update fstab
$ echo -e "$(sudo blkid |grep mapper|awk '{print $2}') /mnt/extvol ext4 defaults 0 0" | sudo tee -a /etc/fstab

# fstab check
$ sudo reboot
$ df -hT
Filesystem           Type   Size  Used Avail Use% Mounted on
/dev/xvda1           ext4   7.8G  867M  6.6G  12% /
tmpfs                tmpfs  1.8G     0  1.8G   0% /dev/shm
/dev/mapper/lvg--extvol-extvol
                     ext4    24G   44M   23G   1% /mnt/extvol
```
