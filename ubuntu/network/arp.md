# arp-scan
同一 network 内で使用されている IP/MAC アドレスの一覧を取得
```bash
$ sudo arp-scan -l --interface en0
```

arp table を確認
```bash
$ arp -a

# or ip command
$ ip neigh
```

arp で MAC アドレスが取れるか確認
```bash
$ sudo arping -c 3 192.168.0.10
```
