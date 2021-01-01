## lsof

Ref: https://orebibou.com/ja/home/201604/20160422_001/

### Summary

```bash
$ lsof
COMMAND     PID   TID     USER   FD      TYPE             DEVICE  SIZE/OFF       NODE NAME
systemd       1           root  cwd       DIR              253,0      4096        128 /
systemd       1           root  rtd       DIR              253,0      4096        128 /
systemd       1           root  txt       REG              253,0   1489960     196956 /usr/lib/systemd/systemd
systemd       1           root  mem       REG              253,0     20032  201382954 /usr/lib64/libuuid.so.1.3.0
systemd       1           root  mem       REG              253,0    252704  201609186 /usr/lib64/libblkid.so.1.1.0
systemd       1           root  mem       REG              253,0     90632  201382920 /usr/lib64/libz.so.1.2.7
systemd       1           root  mem       REG              253,0     19888  201524817 /usr/lib64/libattr.so.1.1.0
systemd       1           root  mem       REG              253,0     19520  201328490 /usr/lib64/libdl-2.17.so
systemd       1           root  mem       REG              253,0    153192  201328867 /usr/lib64/liblzma.so.5.0.99
systemd       1           root  mem       REG              253,0    398272  201328924 /usr/lib64/libpcre.so.1.2.0
systemd       1           root  mem       REG              253,0   2107816  201328483 /usr/lib64/libc-2.17.so
systemd       1           root  mem       REG              253,0    142304  201328516 /usr/lib64/libpthread-2.17.so
systemd       1           root  mem       REG              253,0     88720  201326729 /usr/lib64/libgcc_s-4.8.5-20150702.so.1
systemd       1           root  mem       REG              253,0     44096  201328521 /usr/lib64/librt-2.17.so
systemd       1           root  mem       REG              253,0    260784  201673504 /usr/lib64/libmount.so.1.1.0
systemd       1           root  mem       REG              253,0     91768  201566273 /usr/lib64/libkmod.so.2.2.10
systemd       1           root  mem       REG              253,0    118792  201382927 /usr/lib64/libaudit.so.1.0.0
systemd       1           root  mem       REG              253,0     61648  201649973 /usr/lib64/libpam.so.0.83.1
systemd       1           root  mem       REG              253,0     20024  201524821 /usr/lib64/libcap.so.2.22
systemd       1           root  mem       REG              253,0    147120  201382917 /usr/lib64/libselinux.so.1
systemd       1           root  mem       REG              253,0    164440  202444375 /usr/lib64/ld-2.17.so
systemd       1           root    0u      CHR                1,3       0t0       1028 /dev/null
systemd       1           root    1u      CHR                1,3       0t0       1028 /dev/null
```

* COMMAND: 実行されているコマンド
* PID: プロセスID
* TID: スレッドID
* USER: 実行ユーザ
* FD: ファイルディスクリプタ
  * cwd: カレントディレクトリ
  * txt: テキストファイル
  * mem: メモリマッピングファイル
  * mmap: メモリマッピングデバイス
  * <int>u: 実際のファイルディスクリプタを表す
    * r: 読み取り
    * w: 書き込み
    * u: 読み書き
* TYPE: タイプ
  * REG: 通常ファイル
  * DIR: ディレクトリ
  * FIFO: FIFO
  * CHR: デバイスファイル
  * unix: UNIXドメインソケット
  * IPv4: IPv4ソケット
  * IPv6: IPv6ソケット
* DEVICE: デバイス
* SIZE/OFF: ファイルサイズ
* NODE: プロトコル
* NAME: ファイルまたはポート

### Command 指定
```bash
$ lsof -c python
```

### User 指定
```bash
$ lsof -u app
```

### PID 指定
```bash
$ lsof -p 15208
```

### Network
ネットワークコネクション
```bash
$ lsof -i
```

Port 指定
```bash
$ lsof -i:8080
```

プロトコル指定
```bash
$ lsof -i tcp
$ lsof -i udp
```

### Repeat
1秒ごとに実行
```bash
$ lsof -u app -r 1
```
