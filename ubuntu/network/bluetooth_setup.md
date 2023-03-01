# Setup bluetooth on standalone ubuntu

ref. https://askubuntu.com/questions/1304427/install-bluetooth-driver-in-ubuntu-20-04

```bash
# for Ralink
sudo add-apt-repository ppa:blaze/rtbth-dkms

sudo apt update

sudo apt install rtbth-dkms

sudo su -
cat > /etc/rc.local <<EOF
modprobe rtbth &> /dev/null
EOF
exit

sudo chmod 777 /etc/rc.local
sudo apt install blueman

sudo /etc/init.d/bluetooth start
sudo systemctl start bluetooth
sudo modprobe btusb
sudo systemctl start bluetooth.service
sudo service bluetooth restart
```
