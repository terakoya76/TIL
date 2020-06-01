## Resolver for Route53 in VPC
VPC 内での Route53 CNAME 変更反映速度が少し気になったので調査

### 状況
* VPC
  * ネットワークレンジは `172.30.0.0/16`
  * DNS-enabled
* R53
  * RDS Endpoint の CNAME を management console から変更
  * TTL1

### 現象
```bash
$ max=120
$ for ((i=0; i < $max; i++)); do
    date;
    dig db.mm-test.net +short | head -n1;
    sleep 1;
done
```

TTL1

First - 13sec

```bash
Wed May  6 06:32:20 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:21 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:22 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.

# Change CNAME value from M1 to M2
# 2020年 5月 6日 水曜日 15時32分23秒 JST

Wed May  6 06:32:23 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:24 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:25 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:26 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:27 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:28 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:29 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:30 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:31 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:32 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:33 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:34 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:35 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:36 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:37 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:38 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:39 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:40 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:41 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 06:32:42 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
```

Second - 5sec

```bash
Wed May  6 09:03:30 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:31 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:32 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.

# Change CNAME value from M1 to M2
# 2020年 5月 6日 水曜日 18時03分33秒 JST

Wed May  6 09:03:33 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:34 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:35 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:36 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:37 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:38 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:40 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:41 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:42 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:43 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:44 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:45 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:46 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:47 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:48 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:49 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:50 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:51 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:03:52 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
```

Third - 9sec

```bash
Wed May  6 09:10:54 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:10:56 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:10:57 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.

# Change CNAME value from M2 to M1
# 2020年 5月 6日 水曜日 18時10分58秒 JST

Wed May  6 09:10:58 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:10:59 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:11:00 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:11:01 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:11:02 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:11:03 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:11:04 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:11:05 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:11:06 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:11:07 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:11:08 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:11:09 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:11:10 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:11:11 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:11:12 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:11:13 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:11:14 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:11:15 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:11:16 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:11:17 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
```

TTL5

First - 4sec

```bash
Wed May  6 09:22:04 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:05 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:06 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.

# Change CNAME value from M1 to M2
# 2020年 5月 6日 水曜日 18時22分07秒 JST

Wed May  6 09:22:07 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:08 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:09 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:10 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:11 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:12 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:13 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:14 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:15 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:16 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:17 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:18 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:19 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:20 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:21 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:22 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:23 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:24 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:25 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:22:26 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
```

Second - 13sec

```bash
Wed May  6 09:32:21 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:22 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:23 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.

# Change CNAME value from M1 to M2
# 2020年 5月 6日 水曜日 18時32分24秒 JST

Wed May  6 09:32:24 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:25 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:26 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:27 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:28 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:29 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:30 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:31 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:32 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:33 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:34 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:35 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:36 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:37 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:38 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:39 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:40 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:41 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:42 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:43 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:44 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:45 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:46 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:47 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:32:49 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
```

Third - 15sec

```bash
Wed May  6 09:36:55 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:36:56 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:36:57 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.

# Change CNAME value from M2 to M1
# 2020年 5月 6日 水曜日 18時36分58秒 JST

Wed May  6 09:36:58 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:36:59 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:37:00 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:37:01 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:37:02 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:37:03 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:37:04 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:37:05 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:37:06 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:37:07 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:37:08 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:37:09 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:37:10 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:37:11 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:37:12 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:37:13 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:37:14 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:37:15 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:37:16 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:37:17 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 09:37:18 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
```

### 原因？
* vpc 内の stub/権威の問い合わせロジックに変なトリックがある説
* r53 自体への反映遅延がある説

## Resolver 調査
同一 VPC の EC2 Instance に SSH
dig を見ると `127.0.0.53:53` に問い合わせており、確認してみると `systemd-resolved` に問い合わせを行っていることがわかる。
```bash
$ dig db.mm-test.net
; <<>> DiG 9.11.3-1ubuntu1.11-Ubuntu <<>> db.mm-test.net
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 30758
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;db.mm-test.net.           IN      A

;; ANSWER SECTION:
trE   mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com. 4 IN A 172.30.32.83

;; Query time: 39 msec
;; SERVER: 127.0.0.53#53(127.0.0.53)
;; WHEN: Wed May 06 10:10:41 UTC 2020
;; MSG SIZE  rcvd: 138

$ netstat -anp | fgrep "127.0.0.53"
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      626/systemd-resolve
udp        0      0 127.0.0.53:53           0.0.0.0:*                           626/systemd-resolve
```

`systemd-resolved` が問い合わせを行うのは `172.30.0.2:53`
今回使っている VPC のネットワークレンジが `172.30.0.0/16` なので、+2 した Route53 Custom DNS Server に投げていることがわかる。
* https://docs.aws.amazon.com/ja_jp/Route53/latest/DeveloperGuide/hosted-zone-private-considerations.html

```bash
$ systemd-resolve --status
Global
          DNSSEC NTA: 10.in-addr.arpa
                      16.172.in-addr.arpa
                      168.192.in-addr.arpa
                      17.172.in-addr.arpa
                      18.172.in-addr.arpa
                      19.172.in-addr.arpa
                      20.172.in-addr.arpa
                      21.172.in-addr.arpa
                      22.172.in-addr.arpa
                      23.172.in-addr.arpa
                      24.172.in-addr.arpa
tr 25.172.in-addr.arpa
                      26.172.in-addr.arpa
                      27.172.in-addr.arpa
                      28.172.in-addr.arpa
                      29.172.in-addr.arpa
                      30.172.in-addr.arpa
                      31.172.in-addr.arpa
                      corp
                      d.f.ip6.arpa
                      home
                      internal
                      intranet
                      lan
                      local
                      private
                      test

Link 2 (eth0)
      Current Scopes: DNS
       LLMNR setting: yes
MulticastDNS setting: no
      DNSSEC setting: no
    DNSSEC supported: no
         DNS Servers: 172.30.0.2
          DNS Domain: ap-northeast-1.compute.internal
```

一旦 stub-resolver 側での cache をチェックする
Default は `Cache=yes` なので一応 cache 機構は動いていそう
* https://www.freedesktop.org/software/systemd/man/resolved.conf.html

```bash
$ cat /etc/systemd/resolved.conf
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by
trsion 2.1 of the License, or
#  (at your option) any later version.
#
# Entries in this file show the compile time defaults.
# You can change settings by editing this file.
# Defaults can be restored by simply deleting this file.
#
# See resolved.conf(5) for details

[Resolve]
#DNS=
#FallbackDNS=
#Domains=
#LLMNR=no
#MulticastDNS=no
#DNSSEC=no
#Cache=yes
#DNSStubListener=yes
```

### 直接 Custom DNS Server に問い合わせるようにしてみる
結果、遅延するときは遅延したので stub resolver cache の問題ではなさそう

```bash
$ max=120
$ for ((i=0; i < $max; i++)); do
    date;
    dig @172.30.0.2 db.mm-test.net +short | head -n1;
    sleep 1;
done
```

TTL5

First - 3sec

```bash
Wed May  6 10:27:52 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:27:53 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:27:54 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.

# Change CNAME value from M1 to M2
# 2020年 5月 6日 水曜日 19時27分55秒 JST

Wed May  6 10:27:55 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:27:56 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:27:57 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:27:58 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:27:59 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:28:00 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:28:01 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:28:02 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:28:03 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:28:04 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:28:05 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:28:06 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:28:07 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:28:08 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:28:09 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:28:10 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:28:11 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:28:12 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:28:13 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:28:14 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:28:16 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
```

Second - 4sec

```bash
Wed May  6 10:45:18 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:19 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:21 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.

# Change CNAME value from M2 to M1
# 2020年 5月 6日 水曜日 19時45分22秒 JST

Wed May  6 10:45:22 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:23 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:24 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:25 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:26 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:27 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:28 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:29 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:30 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:31 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:32 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:33 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:34 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:35 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:36 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:37 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:38 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:39 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:40 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:41 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:45:42 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
```

Third - 16sec

```bash
Wed May  6 10:49:18 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:19 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:20 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.

# Change CNAME value from M1 to M2
# 2020年 5月 6日 水曜日 19時49分21秒 JST

Wed May  6 10:49:21 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:22 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:23 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:24 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:25 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:26 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:27 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:28 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:29 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:30 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:31 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:32 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:33 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:34 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:35 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:36 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:37 UTC 2020
mm-test-1.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:38 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:39 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:40 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
Wed May  6 10:49:41 UTC 2020
mm-test-2.xxxx.ap-northeast-1.rds.amazonaws.com.
```

## r53 自体への反映遅延がある説
Ref https://aws.amazon.com/jp/route53/faqs/

こっちが濃厚か
