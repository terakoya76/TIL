# logrotate

```bash
sudo cat > /etc/logrotate.d/new-file <<EOF
/var/log/system-name/info.log {
  daily
  rotate 90
  missingok
  notifempty
  copytruncate
  dateext
  dateformat .%Y-%m-%d
}
EOF
```
