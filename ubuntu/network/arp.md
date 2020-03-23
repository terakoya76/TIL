# arp-scan
同一network内で使用されているIP/MACアドレスの一覧を取得
```bash
$ sudo apt install -y arp-scan
$ sudo arp-scan -l --interface en0
```

Arpテーブルを確認
```bash
$ arp -a

# or ip command
$ ip neigh
```

arpでMACアドレスが取れるか確認
```bash
$ sudo arping -c 3 192.168.0.10
```
