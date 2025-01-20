# fsck

dirty-bit remains on the usb device.

```sh
kernel: [  589.024780] usb 4-4: new SuperSpeed USB device number 2 using xhci_hcd
kernel: [  589.045223] usb 4-4: New USB device found, idVendor=XXX, idProduct=XXX, bcdDevice=XXX
kernel: [  589.045230] usb 4-4: New USB device strings: Mfr=X, Product=X, SerialNumber=X
kernel: [  589.045232] usb 4-4: Product: Mass Storage Device
kernel: [  589.045233] usb 4-4: Manufacturer: XXXXX
kernel: [  589.045235] usb 4-4: SerialNumber: YYYYY
kernel: [  589.054425] usbcore: registered new interface driver usb-storage
kernel: [  589.163311] scsi host2: uas
kernel: [  589.163409] usbcore: registered new interface driver uas
kernel: [  589.744376] FAT-fs (sda1): Volume was not properly unmounted. Some data may be corrupt. Please run fsck.
```

repair the device.
```sh
$ sudo fsck -p /dev/sda1
fsck from util-linux 2.37.2
fsck.fat 4.2 (2021-01-31)
There are differences between boot sector and its backup.
This is mostly harmless. Differences: (offset:original/backup)
  65:01/00
  Not automatically fixing this.
There is no label in boot sector, but there is volume label 'Transcend' stored in root directory
  Auto-copying volume label from root directory to boot sector.
Dirty bit is set. Fs was not properly unmounted and some data may be corrupt.
 Automatically removing dirty bit.

*** Filesystem was changed ***
Writing changes.
/dev/sda1: 598 files, 32650/15270513 clusters
```
