# Pipewire

Ref: https://zenn.dev/mkobayashime/articles/96b476ddbc6a3f

pulseaudio to pipewire
```bash
sudo add-apt-repository ppa:pipewire-debian/pipewire-upstream
sudo apt update
sudo apt install pipewire pipewire-audio-client-libraries libspa-0.2-bluetooth

systemctl --user --now disable pulseaudio.service pulseaudio.socket
systemctl --user mask pulseaudio
systemctl --user --now enable pipewire pipewire-pulse
```

Restart pipewire
```bash
# cf. https://askubuntu.com/questions/1298817/chrome-does-not-reconnect-to-my-mic-when-restarting-pulseaudio
systemctl --user restart pipewire pipewire-pulse
systemctl --user daemon-reload

# Fix issues with existing chrome sessions (page may need to be refreshed)
pkill -f "/opt/google/chrome/chrome --type=utility --utility-sub-type=audio"
```

Reset
```bash
systemctl --user --now disable pipewire pipewire-pulse
systemctl --user --now enable pipewire pipewire-pulse
```

Default Config
```bash
$ pactl info | grep Default
```
