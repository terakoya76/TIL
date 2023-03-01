# `redis-cli`
Ref: https://redis.io/commands/

## Client List
```bash
$ redis-cli -h $REDIS_HOST client list | awk '{print $2}' | cut -d: -f1 | cut -d= -f2 | sort | uniq -c
```

roleとmapping
```bash
$ redis-cli -h $REDIS_HOST client list | awk '{print $2}' | cut -d: -f1 | cut -d= -f2 | sort | uniq -c > client.txt
$ cat client.txt | awk '{ print $2 }' | xargs -I{} aws ec2 describe-instances --filter Name=network-interface.addresses.private-ip-address,Values={} | jq -rc '
.Reservations[].Instances[] as $is | [($is.Tags[] | select(.Key == "Role") | .Value), $is.PrivateIpAddress]' > role.txt
$ join -o 1.1,1.2,2.2 -1 2 -2 1 client.txt role.txt
```

## Summarize Prefix
keys command is for debug due to its heavy load
```bash
$ redis-cli -h $REDIS_HOST keys * | cut -d: -f1-2 | sort | uniq -c

# session を除外
$ redis-cli -h $REDIS_HOST keys "[^session]*" | cut -d: -f1-2 | sort | uniq -c

# 特定の prefix で keys
$ redis-cli -h $REDIS_HOST keys "resque:*[^ip-]*" | cut -d: -f1-5 | sort | uniq -c

# get set values
$ redis-cli -h $REDIS_HOST smembers "resque:workers"
```

requestをblockしないようscanを使うほうが好ましい
```bash
#!/bin/bash
set -eux

next_cursor=0
key_pattern=$1
batch_size=1000
tmp_file=scanbuf.txt
result_file=$2

scan () {
    redis-cli -h $REDIS_HOST scan $next_cursor count $batch_size match $key_pattern | awk '{print $1}' > $tmp_file
    next_cursor=$(cat $tmp_file | head -n1)
    sed '1d' $tmp_file >> $result_file
}

scan
until [ $next_cursor -eq 0 ]
do
    scan
    sleep 0.1
done

rm $tmp_file

exit 0
```

その後集計処理を行う
```bash
$ ./scan.sh "resque:*[^ip-]*" result.txt
$ cat result.txt | cut -d: -f1-5 | sort | uniq -c
```
