# dtruss
dtruss を使うために SIP を無効化して DTrace が使えるようにする必要がある
```bash
$ sudo  csrutil status
System Integrity Protection status: enabled
```

リカバリーモード(起動時に Command + R)で起動し、DTrace の実行制限だけ解除
```bash
$ csrutil enable --without dtrace
```

reboot（DTrace Restrictions が disabled になっている）
```bash
$ sudo csrutil status
System Integrity Protection status: enabled (Custom Configuration).

Configuration:
    Apple Internal: disabled
    Kext Signing: enabled
    Filesystem Protections: enabled
    Debugging Restrictions: enabled
    DTrace Restrictions: disabled
    NVRAM Protections: enabled
    BaseSystem Verification: enabled
```

