# Conntrack

```bash
$ less /var/log/syslog
Apr  4 20:42:33 x-x-x-x kernel: [15977317.778902] nf_conntrack: nf_conntrack: table full, dropping packet
```

## Netfilter Conntrack Sysfs variables

https://github.com/torvalds/linux/blob/master/Documentation/networking/nf_conntrack-sysctl.rst

```bash
$ sudo ls /proc/sys/net/netfilter
nf_conntrack_acct                   nf_conntrack_expect_max                  nf_conntrack_sctp_timeout_established        nf_conntrack_tcp_timeout_last_ack
nf_conntrack_buckets                nf_conntrack_frag6_high_thresh           nf_conntrack_sctp_timeout_heartbeat_acked    nf_conntrack_tcp_timeout_max_retrans
nf_conntrack_checksum               nf_conntrack_frag6_low_thresh            nf_conntrack_sctp_timeout_heartbeat_sent     nf_conntrack_tcp_timeout_syn_recv
nf_conntrack_count                  nf_conntrack_frag6_timeout               nf_conntrack_sctp_timeout_shutdown_ack_sent  nf_conntrack_tcp_timeout_syn_sent
nf_conntrack_dccp_loose             nf_conntrack_generic_timeout             nf_conntrack_sctp_timeout_shutdown_recd      nf_conntrack_tcp_timeout_time_wait
nf_conntrack_dccp_timeout_closereq  nf_conntrack_helper                      nf_conntrack_sctp_timeout_shutdown_sent      nf_conntrack_tcp_timeout_unacknowledged
nf_conntrack_dccp_timeout_closing   nf_conntrack_icmp_timeout                nf_conntrack_tcp_be_liberal                  nf_conntrack_timestamp
nf_conntrack_dccp_timeout_open      nf_conntrack_icmpv6_timeout              nf_conntrack_tcp_loose                       nf_conntrack_udp_timeout
nf_conntrack_dccp_timeout_partopen  nf_conntrack_log_invalid                 nf_conntrack_tcp_max_retrans                 nf_conntrack_udp_timeout_stream
nf_conntrack_dccp_timeout_request   nf_conntrack_max                         nf_conntrack_tcp_timeout_close               nf_log
nf_conntrack_dccp_timeout_respond   nf_conntrack_sctp_timeout_closed         nf_conntrack_tcp_timeout_close_wait          nf_log_all_netns
nf_conntrack_dccp_timeout_timewait  nf_conntrack_sctp_timeout_cookie_echoed  nf_conntrack_tcp_timeout_established
nf_conntrack_events                 nf_conntrack_sctp_timeout_cookie_wait    nf_conntrack_tcp_timeout_fin_wait

```

nf_conntrack_max変更
```bash
$ sudo vim /etc/sysctl.conf
$ sudo sysctl -p
vm.swappiness = 10
net.nf_conntrack_max = 131072
$ sudo cat /proc/sys/net/netfilter/nf_conntrack_max
131072
```
