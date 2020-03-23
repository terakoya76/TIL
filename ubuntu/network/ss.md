# ss

## Summary

```bash
$ sudo ss -tiepm
State                      Recv-Q                      Send-Q                                             Local Address:Port                                             Peer Address:Port                       Process
ESTAB                      0                           0                                                      10.0.2.15:ssh                                                  10.0.2.2:64587                       timer:(keepalive,116min,0) ino:49796 sk:1 <->
         skmem:(r0,rb131072,t0,tb87040,f4096,w0,o0,bl0,d0) cubic rto:204 rtt:0.19/0.092 ato:40 mss:1460 pmtu:1500 rcvmss:1392 advmss:1460 cwnd:10 bytes_sent:18033 bytes_acked:18033 bytes_received:6973 segs_out:341 segs_in:454 data_segs_out:327 data_segs_in:125 send 614.7Mbps lastsnd:16 lastrcv:16 lastack:16 pacing_rate 1226.2Mbps delivery_rate 147.8Mbps delivered:328 app_limited busy:68ms rcv_space:14600 rcv_ssthresh:64076 minrtt:0.056
```

* `-t` filter tcp socket
* `-i` w/ tcp internal info
* `-e` extended socket info
* `-p` process info
* `-m` memory usage

## 特定のポートを利用する socket を絞る

```bash
$ sudo ss -at '( dport = :5432 )'
```

## 特定の fd を使っている socket を絞る
straceとかでfdにあたりをつける
```bash
sudo ss -tp | grep "fd=28"
```
