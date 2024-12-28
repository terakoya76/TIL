# Add new SSD to Ubuntu

search new SSD
```bash
$ sudo parted -l
[sudo] password for terakoya76:
Model: WD Blue SN570 1TB (nvme)
Disk /dev/nvme0n1: 1000GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name                  Flags
 1      1049kB  538MB   537MB   fat32        EFI System Partition  boot, esp
 2      538MB   1000GB  1000GB  ext4


Error: /dev/nvme2n1: unrecognised disk label
Model: WD Blue SN570 500GB (nvme)
Disk /dev/nvme2n1: 500GB
Sector size (logical/physical): 512B/512B
Partition Table: unknown
Disk Flags:

Error: /dev/nvme1n1: unrecognised disk label
Model: WD_BLACK SN770 2TB (nvme)
Disk /dev/nvme1n1: 2000GB
Sector size (logical/physical): 512B/512B
Partition Table: unknown
Disk Flags:
```

create partition
```sh
$ sudo parted /dev/nvme1n1
GNU Parted 3.4
Using /dev/nvme1n1
Welcome to GNU Parted! Type 'help' to view a list of commands.

# use gpt as partition format
(parted) mklabel  gpt

# create partition
(parted) mkpart
Partition name?  []?
File system type?  [ext2]? ext4
Start? 0%
End? 100%

(parted) print
Model: WD_BLACK SN770 2TB (nvme)
Disk /dev/nvme1n1: 2000GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name  Flags
 1      1049kB  2000GB  2000GB  ext4

(parted) quit
Information: You may need to update /etc/fstab.
```

create filesystem
```sh
# ensure FS is created
$ cat /proc/partitions | grep nvme
 259        0  488386584 nvme2n1
 259        1  976762584 nvme0n1
 259        2     524288 nvme0n1p1
 259        3  976236544 nvme0n1p2
 259        4 1953514584 nvme1n1
 259        5 1953513472 nvme1n1p1 <- new

$ mkfs.ext4 /dev/nvme1n1p1
```

adjust mountpoint
```sh
# evacuate original data
$ sudo mv /home /home_orig

# mount filesystem
$ sudo mkdir /home
$ sudo mount /dev/nvme1n1p1 /home

# copy original data
$ sudo mkdir /home/$USER
$ sudo chown $USER.$USER /home/$USER/
$ sudo rsync -aXSAUH --progress --preallocate /home_orig/$USER/ /home/$USER

$ df -h | grep nvme
/dev/nvme0n1p2  916G  573G  297G  66% /
/dev/nvme0n1p1  511M  6.1M  505M   2% /boot/efi
/dev/nvme1n1p1  1.8T  476G  1.3T  28% /home
```

persist mount
```sh
$ ls -l /dev/disk/by-uuid/
lrwxrwxrwx 15 root 28 12月 16:56 <uuid> -> ../../nvme0n1p2
lrwxrwxrwx 15 root 28 12月 17:08 <uuid> -> ../../nvme1n1p1

$ sudo vim /etc/fstab
(snip)
UUID=<uuid-of-nvme0n1p2> /               ext4    errors=remount-ro 0 1
UUID=<uuid-of-nvme1n1p1> /home           ext4    defaults          0 0
```
