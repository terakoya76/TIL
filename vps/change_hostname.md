# Change Hostname

ubuntu

```bash
h=raspberrypi-1

sudo sed -i "s/^preserve_hostname: false/preserve_hostname: true/g" /etc/cloud/cloud.cfg
sudo hostnamectl set-hostname ${h}
 ```
