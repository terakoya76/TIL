# ip
## routing table
```bash
# all table entry
$ ip route show table all

$ ip rule show
0:      from all lookup local
32765:  not from all fwmark 0x100cf lookup 65743
32766:  from all lookup main
32767:  from all lookup default

$ ip route show table  65743
```
