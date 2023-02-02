# Cronjob log
実行有無の log
```bash
# install for local mailbox
sudo apt install -y postfix

sudo vim /etc/rsyslog.d/50-default.conf

# comment-in
cron.*                         /var/log/cron.log

sudo systemctl rsyslog restart
sudo less /var/log/cron
```

script 自体の log
```
0 * * * * /usr/local/bin/myjob > /var/log/myjob.log 2>&1
```
