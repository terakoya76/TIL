## Unicorn Restart

Normal Restart
```bash
# stop
$ kill -QUIT `cat /path/to/unicorn.pid`
# start
$ bundle exec unicorn_rails -c config/unicorn.rb -D
```

Graceful Restart
```bash
$ i=0
$ max_retry=n
$ workers=0
$ expected_worker=xx

# restart
$ kill -USR2 `cat /path/to/unicorn.pid`

# unicorn.pid -> unicorn.pid.oldbin の rename を確認し、unicorn.pid が新マスターのものであることを保証
$ while [ $i -ne $max_retry ]
do
    sleep(1)
    test -f /path/to/unicorn.pid.oldbin
done

# 新マスターの立ち上がりを待つ
$ i=0
$ while [ $i -ne $max_retry ]
do
    sleep(1)
    test -f /path/to/unicorn.pid
done

# worker が立ち上がり切るのを待つ
$ while [ $workers -eq $expected_worker ]
do
    sleep 1
    workers=$(pgrep -P `cat /path/to/unicorn.pid` | wc -l)
done
```
