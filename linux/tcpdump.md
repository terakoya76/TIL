## tcpdump

Ref: https://memo.yuuk.io/entry/2018/01/25/221111

```bash
$ tcpdump -tttt -l -i eth0 -A -n -s 0 dst port 3306
```

* `-tttt` timestamp
* `-l` line buffered
* `-i` interface designation
* `-A` in Ascii
* `-n` no IP reverse lookup
* `-s 0` no truncation of output
