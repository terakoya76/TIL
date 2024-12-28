# nvidia driver

Ref: https://qiita.com/porizou1/items/74d8264d6381ee2941bd

## Specific Version
```bash
# enter BIOS to disable safe-boot
$ sudo systemctl reboot --firmware-setup

# for ubuntu-drivers devices command
$ sudo apt install -y ubuntu-drivers-common

# install recommended driver
$ ubuntu-drivers devices
== /sys/devices/pci0000:00/0000:00:03.1/0000:2d:00.0 ==
modalias : pci:v000010DEd000024C9sv00001462sd00005059bc03sc00i00
vendor   : NVIDIA Corporation
driver   : nvidia-driver-545 - distro non-free
driver   : nvidia-driver-560 - third-party non-free recommended
driver   : nvidia-driver-560-open - third-party non-free
driver   : nvidia-driver-535 - distro non-free
driver   : nvidia-driver-535-open - distro non-free
driver   : nvidia-driver-555-open - third-party non-free
driver   : nvidia-driver-550-open - third-party non-free
driver   : nvidia-driver-535-server-open - distro non-free
driver   : nvidia-driver-535-server - distro non-free
driver   : nvidia-driver-550 - third-party non-free
driver   : nvidia-driver-545-open - distro non-free
driver   : nvidia-driver-555 - third-party non-free
driver   : xserver-xorg-video-nouveau - distro free builtin

$ sudo apt install -y nvidia-driver-560
```

## Cuda
Ref: https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=22.04&target_type=deb_network

```bash
$ wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
$ sudo dpkg -i cuda-keyring_1.1-1_all.deb
$ sudo apt-get update
$ sudo apt-get -y install cuda-toolkit-12-6

$ sudo apt-get install -y nvidia-open
$ sudo apt-get install -y cuda-drivers

# check enabled
$ nvidia-smi
```

## Apply Window System

1. `Settings`
2. `Software & Updates`
3. `Additional Drivers`
4. Choose nvidia driver you want to use other than default X.org driver

## After Suspension
Ref: https://discuss.pytorch.org/t/userwarning-cuda-initialization-cuda-unknown-error-this-may-be-due-to-an-incorrectly-set-up-environment-e-g-changing-env-variable-cuda-visible-devices-after-program-start-setting-the-available-devices-to-be-zero/129335/3
```bash
$ sudo rmmod nvidia_uvm
$ sudo modprobe nvidia_uvm

# check enabled
$ nvidia-smi
```
