# Setup bluetooth on standalone Ubuntu

ref. https://askubuntu.com/questions/1304427/install-bluetooth-driver-in-ubuntu-20-04

Download Driver
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
```

then, enable bluetooth
```bash
sudo apt install blueman

sudo modprobe btusb
sudo systemctl restart bluetooth
sudo service bluetooth restart
```

## Introduce pipewire
ref: https://pipewire-debian.github.io/pipewire-debian/#2-install-pipewire-or-blueman-git

Introduce
```bash
sudo add-apt-repository ppa:pipewire-debian/pipewire-upstream
sudo add-apt-repository ppa:pipewire-debian/wireplumber-upstream
sudo apt update

sudo apt install gstreamer1.0-pipewire libpipewire-0.3-{0,dev,modules} libspa-0.2-{bluetooth,dev,jack,modules} pipewire{,-{audio-client-libraries,pulse,bin,jack,alsa,v4l2,libcamera,locales,tests}}
sudo apt install wireplumber{,-doc} gir1.2-wp-0.4 libwireplumber-0.4-{0,dev}

# disable PulseAudio
systemctl --user --now disable pulseaudio.{socket,service}
systemctl --user mask pulseaudio

# Since version 0.3.28 conf files are moved to /usr/share/ directory from /etc/.
# You have to copy them to /etc/ directory manually.
# From now /etc/pipewire/ can be used as system wide drop in for user edited conf files.
# conffile overriding behaviour is $HOME/.config/pipewire > /etc/pipewire > /usr/share/pipewire
sudo cp -vRa /usr/share/pipewire /etc/

systemctl --user --now enable pipewire{,-pulse}.{socket,service} filter-chain.service
systemctl --user --now enable wireplumber.service

pactl info | grep '^Server Name'
```

Trouble Shooting
Ref: https://wiki.archlinux.org/title/bluetooth_headset#top-page

```bash
sudo vim /etc/bluetooth/main.conf

[General]
Enable=Control,Gateway,Headset,Media,Sink,Socket,Source
```
