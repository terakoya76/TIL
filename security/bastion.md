# Bastion Server

## NSS

### STNS
https://github.com/STNS/STNS

Installation
* https://stns.jp/ja/install
```bash
$ curl -fsSl https://repo.stns.jp/scripts/apt-repo.sh | sh
$ sudo apt install -y stns-v2 libnss-stns-v2 cache-stnsd jq
```

behavior test
```bash
# whether stns is working
$ stns-key-wrapper terakoya76
$ curl -s http://localhost:1104/v1/users | jq .

# whether nss is working
$ id terakoya76
```

## 2FA
```bash
$ sudo apt install -y libpam-google-authenticator

$ sudo vim /etc/ssh/sshd_config
ChallengeResponseAuthentication yes
AuthenticationMethods publickey,keyboard-interactive
# append
Match User {{ ansible_user }}
  AuthenticationMethods publickey

$ sudo vim /etc/pam.d/sshd
# @include common-auth
auth required pam_google_authenticator.so nullok

$ sudo vim /etc/profile.d/google-authenticator.sh
#!/bin/sh

if [ "$USER" != "root" -a "$USER" != "{{ ansible_user }}" ]; then
  if [ ! -f "$HOME/.google_authenticator" ]; then
    trap 'exit' SIGINT
    echo "google-authenticator の初期設定を行います"
    /usr/bin/google-authenticator -t -d -W -u -f
    trap SIGINT
  fi
fi
```

## Console Log
```bash
$ sudo mkdir /var/log/script
$ sudo chmod 777 /var/log/script

$ sudo vim /etc/profile.d/console-log.sh
#!/bin/sh

P_PROC=`ps aux | grep $PPID | grep sshd | awk '{ print $11 }'`
if [ "$P_PROC" = sshd: ]; then
  script -q /var/log/script/`whoami`_`date '+%Y%m%d_%H_%M_%S'`.log
  exit
fi
```
