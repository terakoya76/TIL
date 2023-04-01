# apt install without internet connection

```bash
# on machine with internet connection
mkdir container_dir
docker run -it -v host_dir:$(pwd)/container_dir ubuntu:20.04

cd <path to container_dir>
apt update

# fetch build info for target machine
kver=5.4.0-42
sudo apt-get -qq --print-uris install build-essential linux-headers-${kver} | cut -d\' -f 2 > uris.txt
wget --content-disposition -i uris.txt
```

Copy downloaded `*.deb` files to USB device.


```bash
# on machine without internet connection
sudo dpkg -i *.deb
```
