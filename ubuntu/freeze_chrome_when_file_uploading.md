# Freeze Chrome when file uploading

ref: https://bugs.chromium.org/p/chromium/issues/detail?id=1315684#c17

```bash
sudo apt install -y dconf-editor
dconf write /org/gnome/desktop/sound/input-feedback-sounds false
```
