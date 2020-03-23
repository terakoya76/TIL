# Slack Huddle Screen Share provides block out screen

cf. https://askubuntu.com/questions/1404516/screen-turns-yellow-even-using-the-live-option-ubuntu-22-04

waylandを無効化する必要がある
```bash
sudo vim /etc/gdm3/custom.conf

# comment out this
WaylandEnable=false

sudo systemctl restart gdm3
```

ただこうすると、xorg下で、nvidia Graphic BoardにつながったディスプレイがYellowGreen配色になってしまい、見られたものでない。

そこでsystem settingsからColor Profileを `Bruce RGB` に変更することで、配色の問題を解消する
