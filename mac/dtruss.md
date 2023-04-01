# dtruss
dtrussを使うためにSIPを無効化してDTraceが使えるようにする必要がある
```bash
$ sudo  csrutil status
System Integrity Protection status: enabled
```

リカバリーモード（起動時にCommand + R）で起動し、DTraceの実行制限だけ解除
```bash
$ csrutil enable --without dtrace
```

reboot（DTrace Restrictionsがdisabledになっている）
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

