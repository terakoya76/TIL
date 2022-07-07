# Socket Backlog

## Unicorn `11: Resource temporarily unavailable`
Ref: https://qiita.com/sakusrai/items/5e3e9b9475d7ff3ba64e

```bash
$ sysctl net.core.somaxconn
net.core.somaxconn = 128

$ ss -ax | grep -e unicorn
u_str  LISTEN     129    128    /path/to/unicorn.sock 60996                 * 0
u_str  ESTAB      0      0      /path/to/unicorn.sock 1672149               * 0
u_str  ESTAB      0      0      /path/to/unicorn.sock 1666246               * 0
u_str  ESTAB      0      0      /path/to/unicorn.sock 1674255               * 0
u_str  ESTAB      0      0      /path/to/unicorn.sock 1676848               * 0

# soft limit を伸ばす
$ sudo sysctl -w net.core.somaxconn=256
net.core.somaxconn = 256

# restart process
$ restart unicorn

$ ss -ax | grep -e unicorn
u_str  LISTEN     0      256    /path/to/unicorn.sock 1698588               * 0
u_str  ESTAB      0      0      /path/to/unicorn.sock 1702421               * 1702420
```
