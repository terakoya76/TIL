## IP Block with Stackprof

Ref: https://totem3.hatenablog.jp/entry/2019/01/07/215807

### Error Stacktrace

handle_interrupt が呼ばれているので、stackprof の wall mode timer によって割り込まれて connection が終了してしまうという記事中の現象に酷似している
```
vendor/bundle/ruby/2.5.0/gems/mysql2-0.4.10/lib/mysql2/client.rb:120:in `_query': Mysql2::Error: Can't connect to MySQL server on 'my-mysql.com' (4): <SOME-SQL> (ActiveRecord::StatementInvalid)
from vendor/bundle/ruby/2.5.0/gems/mysql2-0.4.10/lib/mysql2/client.rb:120:in `block in query'
from vendor/bundle/ruby/2.5.0/gems/mysql2-0.4.10/lib/mysql2/client.rb:119:in `handle_interrupt'
from vendor/bundle/ruby/2.5.0/gems/mysql2-0.4.10/lib/mysql2/client.rb:119:in `query'
from vendor/bundle/ruby/2.5.0/gems/rack-mini-profiler-2.2.0/lib/patches/db/mysql2.rb:25:in `block in query'
from vendor/bundle/ruby/2.5.0/gems/rack-mini-profiler-2.2.0/lib/patches/sql_patches.rb:12:in `record_sql'
from vendor/bundle/ruby/2.5.0/gems/rack-mini-profiler-2.2.0/lib/patches/db/mysql2.rb:24:in `query'
from vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.4.3/lib/active_record/connection_adapters/abstract_mysql_adapter.rb:187:in `block (2 levels) in execute'
from vendor/bundle/ruby/2.5.0/gems/activesupport-5.2.4.3/lib/active_support/dependencies/interlock.rb:48:in `block in permit_concurrent_loads'
from vendor/bundle/ruby/2.5.0/gems/activesupport-5.2.4.3/lib/active_support/concurrency/share_lock.rb:187:in `yield_shares'
from vendor/bundle/ruby/2.5.0/gems/activesupport-5.2.4.3/lib/active_support/dependencies/interlock.rb:47:in `permit_concurrent_loads'
from vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.4.3/lib/active_record/connection_adapters/abstract_mysql_adapter.rb:186:in `block in execute'
from vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.4.3/lib/active_record/connection_adapters/abstract_adapter.rb:581:in `block (2 levels) in log'
from /opt/rubies/ruby-2.5.8/lib/ruby/2.5.0/monitor.rb:235:in `mon_synchronize'
from vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.4.3/lib/active_record/connection_adapters/abstract_adapter.rb:580:in `block in log'
from vendor/bundle/ruby/2.5.0/gems/activesupport-5.2.4.3/lib/active_support/notifications/instrumenter.rb:23:in `instrument'
from vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.4.3/lib/active_record/connection_adapters/abstract_adapter.rb:571:in `log'
from vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.4.3/lib/active_record/connection_adapters/abstract_mysql_adapter.rb:185:in `execute'
from vendor/bundle/ruby/2.5.0/gems/activerecord-5.2.4.3/lib/active_record/connection_adapters/mysql/database_statements.rb:28:in `execute'
...
(snip)
```

* https://github.com/brianmario/mysql2/blob/0.4.10/lib/mysql2/client.rb#L119-L121
* https://docs.ruby-lang.org/ja/latest/class/Thread.html#S_HANDLE_INTERRUPT

### Reproduce
wall mode で重い処理を走らせる
```ruby
StackProf.run(mode: :wall, raw: true, out: dir.join('cpu.dump').to_s) do
  # do heavy ActiveRecord thing
end
```

再現
```sql
mysql> select * from performance_schema.host_cache where ip = '10.1.64.49'\G
*************************** 1. row ***************************
                                        IP: 10.1.64.49
                                      HOST: NULL
                            HOST_VALIDATED: YES
                        SUM_CONNECT_ERRORS: 7
                 COUNT_HOST_BLOCKED_ERRORS: 0
           COUNT_NAMEINFO_TRANSIENT_ERRORS: 0
           COUNT_NAMEINFO_PERMANENT_ERRORS: 1
                       COUNT_FORMAT_ERRORS: 0
           COUNT_ADDRINFO_TRANSIENT_ERRORS: 0
           COUNT_ADDRINFO_PERMANENT_ERRORS: 0
                       COUNT_FCRDNS_ERRORS: 0
                     COUNT_HOST_ACL_ERRORS: 0
               COUNT_NO_AUTH_PLUGIN_ERRORS: 0
                  COUNT_AUTH_PLUGIN_ERRORS: 0
                    COUNT_HANDSHAKE_ERRORS: 149
                   COUNT_PROXY_USER_ERRORS: 0
               COUNT_PROXY_USER_ACL_ERRORS: 0
               COUNT_AUTHENTICATION_ERRORS: 0
                          COUNT_SSL_ERRORS: 0
         COUNT_MAX_USER_CONNECTIONS_ERRORS: 0
COUNT_MAX_USER_CONNECTIONS_PER_HOUR_ERRORS: 0
             COUNT_DEFAULT_DATABASE_ERRORS: 0
                 COUNT_INIT_CONNECT_ERRORS: 0
                        COUNT_LOCAL_ERRORS: 0
                      COUNT_UNKNOWN_ERRORS: 0
                                FIRST_SEEN: 2020-12-09 23:24:06
                                 LAST_SEEN: 2020-12-10 10:16:41
                          FIRST_ERROR_SEEN: 2020-12-09 23:24:06
                           LAST_ERROR_SEEN: 2020-12-10 10:16:41
1 row in set (0.00 sec)
```

cpu mode で同様の処理を走らせる
```ruby
StackProf.run(mode: :cpu, raw: true, out: dir.join('cpu.dump').to_s) do
  # do heavy ActiveRecord thing
end
```

再現しない
```sql
mysql> select * from performance_schema.host_cache where ip = '10.1.64.49'\G
*************************** 1. row ***************************
                                        IP: 10.1.64.49
                                      HOST: NULL
                            HOST_VALIDATED: YES
                        SUM_CONNECT_ERRORS: 0
                 COUNT_HOST_BLOCKED_ERRORS: 0
           COUNT_NAMEINFO_TRANSIENT_ERRORS: 0
           COUNT_NAMEINFO_PERMANENT_ERRORS: 1
                       COUNT_FORMAT_ERRORS: 0
           COUNT_ADDRINFO_TRANSIENT_ERRORS: 0
           COUNT_ADDRINFO_PERMANENT_ERRORS: 0
                       COUNT_FCRDNS_ERRORS: 0
                     COUNT_HOST_ACL_ERRORS: 0
               COUNT_NO_AUTH_PLUGIN_ERRORS: 0
                  COUNT_AUTH_PLUGIN_ERRORS: 0
                    COUNT_HANDSHAKE_ERRORS: 254
                   COUNT_PROXY_USER_ERRORS: 0
               COUNT_PROXY_USER_ACL_ERRORS: 0
               COUNT_AUTHENTICATION_ERRORS: 0
                          COUNT_SSL_ERRORS: 0
         COUNT_MAX_USER_CONNECTIONS_ERRORS: 0
COUNT_MAX_USER_CONNECTIONS_PER_HOUR_ERRORS: 0
             COUNT_DEFAULT_DATABASE_ERRORS: 0
                 COUNT_INIT_CONNECT_ERRORS: 0
                        COUNT_LOCAL_ERRORS: 0
                      COUNT_UNKNOWN_ERRORS: 0
                                FIRST_SEEN: 2020-12-09 23:24:06
                                 LAST_SEEN: 2020-12-10 10:20:40
                          FIRST_ERROR_SEEN: 2020-12-09 23:24:06
                           LAST_ERROR_SEEN: 2020-12-10 10:17:53
1 row in set (0.00 sec)
```

### Verification
strace すると profile 開始後から `SIGALRM` が飛ぶのを確認
```bash
$ sudo strace -p 10685
20:35:41.190514 mkdir("/var/app/myapp/releases/20201210095154/tmp/profiler/hoge.1607600141", 0777) = 0
20:35:41.190777 open("/var/app/myapp/releases/20201210095154/tmp/profiler/hoge.1607600141/sql.log", O_WRONLY|O_APPEND|O_CLOEXEC) = -1 ENOENT (No such file or directory)
20:35:41.190903 open("/var/app/myapp/releases/20201210095154/tmp/profiler/hoge.1607600141/sql.log", O_WRONLY|O_CREAT|O_EXCL|O_APPEND|O_CLOEXEC, 0666) = 35
20:35:41.190983 ioctl(35, TCGETS, 0x7fff513b7860) = -1 ENOTTY (Inappropriate ioctl for device)
20:35:41.191337 flock(35, LOCK_EX)      = 0
20:35:41.191409 fstat(35, {st_mode=S_IFREG|0644, st_size=0, ...}) = 0
20:35:41.191509 write(35, "# Logfile created on 2020-12-10 20:35:41 +0900 by logger.rb/61378\n", 66) = 66
20:35:41.191586 flock(35, LOCK_UN)      = 0
20:35:41.191701 rt_sigaction(SIGALRM, {0x7fbc44da07c0, [], SA_RESTORER|SA_RESTART|SA_SIGINFO, 0x7fbc5987b390}, NULL, 8) = 0
20:35:41.191774 setitimer(ITIMER_REAL, {it_interval={0, 1000}, it_value={0, 1000}}, NULL) = 0
20:35:41.194788 --- SIGALRM {si_signo=SIGALRM, si_code=SI_KERNEL} ---
20:35:41.194850 rt_sigreturn({mask=[]}) = 136
20:35:41.195825 --- SIGALRM {si_signo=SIGALRM, si_code=SI_KERNEL} ---
20:35:41.195867 rt_sigreturn({mask=[]}) = 94774112081408
20:35:41.196978 --- SIGALRM {si_signo=SIGALRM, si_code=SI_KERNEL} ---
20:35:41.197225 rt_sigreturn({mask=[]}) = 0
20:35:41.199826 --- SIGALRM {si_signo=SIGALRM, si_code=SI_KERNEL} ---
20:35:41.199873 rt_sigreturn({mask=[]}) = 94774024515200
20:35:41.200569 poll([{fd=25, events=POLLIN|POLLPRI}], 1, 0) = 0 (Timeout)
20:35:41.200982 write(25, "\27\3\3\0\260\273\213\346\225+q\"\311|d\314\2\321\333\350\33\375\222\21h\30$\0370\371[2\327\336\362\325\245k\30p\22\310\367s:\356\370\372\2716\260\222\35\203'\340\330\0\324oG\372\266\243\305\203qN\331
\265p\223\260H\343\311|oF\t\331\357\316&\231\30\364\306[q!8\23\253h\323\331-\16\37\271vn0\377\10\341\252\10\303\210\330\177\23\236\0\266\306w\r\25\10\177\252\273\226\317i\242c\375\326N~V\221\274\377k\265\36\206VZ3t\n:\277\372\3
30+\261YT4\225t647\266\232\275/\236\316]L\5\337'k\366\30p!\220\25787", 181) = 181
20:35:41.201188 ppoll([{fd=25, events=POLLIN}], 1, NULL, NULL, 8) = ? ERESTARTNOHAND (To be restarted if no handler)
20:35:41.202680 --- SIGALRM {si_signo=SIGALRM, si_code=SI_KERNEL} ---
20:35:41.202718 rt_sigreturn({mask=[]}) = -1 EINTR (Interrupted system call)
20:35:41.202813 --- SIGALRM {si_signo=SIGALRM, si_code=SI_KERNEL} ---
20:35:41.202842 rt_sigreturn({mask=[]}) = 94774030557392
20:35:41.202992 ppoll([{fd=25, events=POLLIN}], 1, NULL, NULL, 8) = 1 ([{fd=25, revents=POLLIN}])
20:35:41.203746 read(25, "\27\3\3\v\20", 5) = 5
20:35:41.203821 --- SIGALRM {si_signo=SIGALRM, si_code=SI_KERNEL} ---
20:35:41.203852 rt_sigreturn({mask=[]}) = 5
```

`connect` して non-blocking に socket が ready になるのを待つ。
そして `EINTR` を食らい、`shutdown` されている。
これが `COUNT_HANDSHAKE_ERRORS` が increment される原因

```bash
20:35:41.254740 socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) = 36
20:35:41.254814 fcntl(36, F_GETFL)      = 0x2 (flags O_RDWR)
20:35:41.254866 fcntl(36, F_SETFL, O_RDWR|O_NONBLOCK) = 0
20:35:41.254918 connect(36, {sa_family=AF_INET, sin_port=htons(3306), sin_addr=inet_addr("10.1.224.239")}, 16) = -1 EINPROGRESS (Operation now in progress)
20:35:41.255002 poll([{fd=36, events=POLLOUT}], 1, 120000) = ? ERESTART_RESTARTBLOCK (Interrupted by signal)
20:35:41.255878 --- SIGALRM {si_signo=SIGALRM, si_code=SI_KERNEL} ---
20:35:41.255915 rt_sigreturn({mask=[]}) = -1 EINTR (Interrupted system call)
20:35:41.255996 shutdown(36, SHUT_RDWR) = 0
20:35:41.256056 close(36)               = 0
```

以降同様のログが複数。 retry している
* https://github.com/brianmario/mysql2/blob/3b9a26708fa86aba23763626331eb317ed457cc1/ext/mysql2/client.c#L438L457


接続に成功（`getsocketopt`）すると処理が進む
```bash
20:35:57.289037 connect(36, {sa_family=AF_INET, sin_port=htons(3306), sin_addr=inet_addr("10.1.224.239")}, 16) = -1 EINPROGRESS (Operation now in progress)
20:35:57.289516 poll([{fd=36, events=POLLOUT}], 1, 105000) = 1 ([{fd=36, revents=POLLOUT}])
20:35:57.296057 --- SIGALRM {si_signo=SIGALRM, si_code=SI_KERNEL} ---
20:35:57.296097 rt_sigreturn({mask=[]}) = 1
20:35:57.296136 getsockopt(36, SOL_SOCKET, SO_ERROR, [0], [4]) = 0
20:35:57.296179 fcntl(36, F_GETFL)      = 0x802 (flags O_RDWR|O_NONBLOCK)
20:35:57.296215 fcntl(36, F_SETFL, O_RDWR) = 0
20:35:57.296258 setsockopt(36, SOL_TCP, TCP_NODELAY, [1], 4) = 0
20:35:57.296298 setsockopt(36, SOL_SOCKET, SO_KEEPALIVE, [1], 4) = 0
20:35:57.296340 poll([{fd=36, events=POLLIN|POLLPRI}], 1, 105000) = 1 ([{fd=36, revents=POLLIN}])
20:35:57.296388 recvfrom(36, "N\0\0\0\n5.7.22-log\0s[\1\0\4Z\177Q[\10)4\0\377\377-\2\0\377\301\25\0\0\0\0\0\0\0\0\0\0p3\vu/cl`B]3{\0mysql_native_password\0", 16384, 0, NULL, NULL) = 82
```

ruby file を読んだり profile 結果を書き出したりする
```bash
20:35:57.333874 connect(36, {sa_family=AF_INET, sin_port=htons(3306), sin_addr=inet_addr("10.1.224.239")}, 16) = -1 EINPROGRESS (Operation now in progress)
20:35:57.333947 poll([{fd=36, events=POLLOUT}], 1, 120000) = ? ERESTART_RESTARTBLOCK (Interrupted by signal)
20:35:57.334850 --- SIGALRM {si_signo=SIGALRM, si_code=SI_KERNEL} ---
20:35:57.334882 rt_sigreturn({mask=[]}) = -1 EINTR (Interrupted system call)
20:35:57.334945 shutdown(36, SHUT_RDWR) = 0
20:35:57.335004 close(36)               = 0
20:35:57.335834 --- SIGALRM {si_signo=SIGALRM, si_code=SI_KERNEL} ---
20:35:57.335880 rt_sigreturn({mask=[]}) = 105
20:35:57.336132 write(35, "D, [2020-12-10T20:35:57.336064 #16408] DEBUG -- :    (4.2ms) <SQL STATEMENT>\n", 992) = 992
```

fd35 は profile output
```bash
$ sudo lsof -p 16408 | less
bundle  16408  app   35w      REG              259,1     1508 1798560 /var/app/myapp/releases/20201210095154/tmp/profiler/hoge.1607600141/sql.log
```

最後に connection error を吐く
```bash
20:35:58.480122 writev(29, ["error] hoge#show\r\n (ActiveRecord::StatementInvalid) \"Mysql2::Error: Can't connect to MySQL\r\n server...\r\nMime-Version: 1.0\r\nContent-Type: text/plain;\r\n charset=UTF-8\r\nContent-Transfer-Encoding: qu
oted-printable\r\n\r\nAn ActiveRecord::StatementInvalid occurred in hoge#show:\r\n\r\n  Mysql2::Error: Can't connect to MySQL server on 'my-mysql.com' (4): <SQL STATEMENT>\r\n      =\r\n\r\n"..., 8138
}, {"  * SERVER_PROTOCOL                                        : HTTP/1.0\r\n", 71}], 2) = 8209
```

tcpdump からも handshake 後にclient 側から connection を切ってることがわかる（seq 番号が interleave していて読みにくいが）
```bash
$ sudo tcpdump -tttt -l -i ens5 -n -s 0 dst port 3306
2020-12-10 23:39:06.964177 IP 10.1.64.49.50478 > 10.1.224.239.3306: Flags [S], seq 2068265327, win 26883, options [mss 8961,sackOK,TS val 13729445 ecr 0,nop,wscale 7], length 0
2020-12-10 23:39:06.966531 IP 10.1.64.49.50478 > 10.1.224.239.3306: Flags [R], seq 2068265328, win 0, length 0
2020-12-10 23:39:06.967268 IP 10.1.64.49.50480 > 10.1.224.239.3306: Flags [S], seq 3955329278, win 26883, options [mss 8961,sackOK,TS val 13729445 ecr 0,nop,wscale 7], length 0
2020-12-10 23:39:06.968546 IP 10.1.64.49.50482 > 10.1.224.239.3306: Flags [S], seq 686965461, win 26883, options [mss 8961,sackOK,TS val 13729446 ecr 0,nop,wscale 7], length 0
2020-12-10 23:39:06.969525 IP 10.1.64.49.50484 > 10.1.224.239.3306: Flags [S], seq 1392555375, win 26883, options [mss 8961,sackOK,TS val 13729446 ecr 0,nop,wscale 7], length 0
2020-12-10 23:39:06.969575 IP 10.1.64.49.50480 > 10.1.224.239.3306: Flags [R], seq 3955329279, win 0, length 0
2020-12-10 23:39:06.970507 IP 10.1.64.49.50486 > 10.1.224.239.3306: Flags [S], seq 1673942428, win 26883, options [mss 8961,sackOK,TS val 13729446 ecr 0,nop,wscale 7], length 0
2020-12-10 23:39:06.970841 IP 10.1.64.49.50482 > 10.1.224.239.3306: Flags [R], seq 686965462, win 0, length 0
2020-12-10 23:39:06.971437 IP 10.1.64.49.50488 > 10.1.224.239.3306: Flags [S], seq 1092672851, win 26883, options [mss 8961,sackOK,TS val 13729446 ecr 0,nop,wscale 7], length 0
2020-12-10 23:39:06.971810 IP 10.1.64.49.50484 > 10.1.224.239.3306: Flags [R], seq 1392555376, win 0, length 0
2020-12-10 23:39:06.972449 IP 10.1.64.49.50490 > 10.1.224.239.3306: Flags [S], seq 3351616331, win 26883, options [mss 8961,sackOK,TS val 13729447 ecr 0,nop,wscale 7], length 0
2020-12-10 23:39:06.972795 IP 10.1.64.49.50486 > 10.1.224.239.3306: Flags [R], seq 1673942429, win 0, length 0
2020-12-10 23:39:06.973466 IP 10.1.64.49.50492 > 10.1.224.239.3306: Flags [S], seq 1668009946, win 26883, options [mss 8961,sackOK,TS val 13729447 ecr 0,nop,wscale 7], length 0
2020-12-10 23:39:06.973728 IP 10.1.64.49.50488 > 10.1.224.239.3306: Flags [R], seq 1092672852, win 0, length 0
2020-12-10 23:39:06.974418 IP 10.1.64.49.50494 > 10.1.224.239.3306: Flags [S], seq 3865037642, win 26883, options [mss 8961,sackOK,TS val 13729447 ecr 0,nop,wscale 7], length 0
```

### Mitigation
1. mode cpu で profile を取る
```ruby
StackProf.run(mode: :cpu, raw: true, out: dir.join('cpu.dump').to_s) do
  # do heavy ActiveRecord thing
end
```

2. interval を default 値の 1000us から 10000us に上げる
```ruby
StackProf.run(mode: :wall, raw: true, interval: 10000, out: dir.join('cpu.dump').to_s) do
  # do heavy ActiveRecord thing
end
```

3. `--skip-name-resolve` の有効化
* ただこれは ip block が起きないだけで、mysql2 内での retry は防げないので性能劣化を起こす（profile 結果が歪む）
