# Setup eth for standalone ubuntu

ref. https://qiita.com/Ihmon/items/7b3e1b81bb9b2c296eff

TargetはRealtek r8125。これのdriverを入れる。
```bash
lspci | grep net
07:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8125 2.5GbE Controller (rev 05)
```

Support ページから、`2.5G Ethernet LINUX driver...` をダウンロード。
* https://www.realtek.com/en/component/zoo/category/network-interface-controllers-10-100-1000m-gigabit-ethernet-pci-express-software


```bash
cd ~/Downloads
tar -jxvf r8125-9.011.00.tar.bz2

# カーネルの更新を行ってもドライバの再登録を行わなくて済むらしい
cat > r8125-9.011.00/dkms.conf <<EOF
PACKAGE_NAME="r8125"
PACKAGE_VERSION="9.011.00"
BUILT_MODULE_NAME[0]="$PACKAGE_NAME"
DEST_MODULE_LOCATION[0]="/updates/dkms"
AUTOINSTALL="YES"
REMAKE_INITRD="YES"
CLEAN="rm src/@PKGNAME@.ko src/*.o || true"
EOF
sudo chmod 777 r8125-9.011.00/dkms.conf
```

Driver Install
```bash
sudo mv r8125-9.011.00 /usr/src/
cd /usr/src/r8125-9.011.00
sudo chmod +x ./autorun.sh
sudo ./autorun.sh

ip a

sudo apt install dkms
```

Driver Install 時、`r8125 Operation not permitted` みたいなエラーで eth が認識されない
```bash
sudo less /var/log/syslog
(snip)
Mar 06 14:32:58 debian-sid kernel: Lockdown: bash: debugfs access is restricted; see man kernel_lockdown.7
```

UEFI に入り、windows secure boot を無効化
```bash
sudo systemctl reboot --firmware-setup

# Advanced -> windows OS Configuration -> xxx
 ```
