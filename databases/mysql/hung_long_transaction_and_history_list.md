# Hung Long Transaction and History List
Ref: https://www.percona.com/blog/2017/05/08/chasing-a-hung-transaction-in-mysql-innodb-history-length-strikes-back/

## Intruction for macOS
```bash
$ conn="--db-driver=mysql --mysql-host=127.0.0.1 --mysql-user=root --mysql-password=root --mysql-db=sbtest"
$ test="/usr/local/Cellar/sysbench/1.0.19/share/sysbench/tests/include/oltp_legacy/oltp.lua"
$ sysbench $conn $test \
    --mysql-table-engine=InnoDB \
    --oltp-table-size=1000000 \
    prepare
watch -n1 'mysql -h127.0.0.1 -uroot -proot -e "show engine innodb status\G" | grep "History list length" >> history_list.txt'
$ sysbench $conn $test \
    --num-threads=16 --max-requests=0 --max-time=120 --oltp-table-size=1000000 \
    --oltp-test-mode=complex --oltp-point-selects=0 --oltp-simple-ranges=0 --oltp-sum-ranges=0 \
    --oltp-order-ranges=0 --oltp-distinct-ranges=0 --oltp-index-updates=1 --oltp-non-index-updates=0 \
    run
$ sysbench $conn $test \
      --mysql-table-engine=InnoDB \
      --oltp-table-size=1000000 \
      cleanup
```

## Verification
### Read/Write Long Txn
ブログと同様に sysbench から負荷をかけている最中に Transaction を開始して History List の遷移を観察します。

```bash
# Term A
## mysql
$ docker-compose up

# Term B
## Watch History List
$ watch -n1 'mysql -h127.0.0.1 -uroot -proot -e "show engine innodb status\G" | grep "History list length" >> history_list_write.txt'

# Term C
## Write Query by sysbench
$ conn="--db-driver=mysql --mysql-host=127.0.0.1 --mysql-user=root --mysql-password=root --mysql-db=sbtest"
$ test="/usr/local/Cellar/sysbench/1.0.19/share/sysbench/tests/include/oltp_legacy/oltp.lua"
$ sysbench $conn $test \
    --num-threads=16 --max-requests=0 --max-time=120 --oltp-table-size=1000000 \
    --oltp-test-mode=complex --oltp-point-selects=0 --oltp-simple-ranges=0 --oltp-sum-ranges=0 \
    --oltp-order-ranges=0 --oltp-distinct-ranges=0 --oltp-index-updates=1 --oltp-non-index-updates=0 \
    run

# Term D
## Simulate Long Transaction Start
mysql> begin; insert into a values(1); select * from a;
Query OK, 0 rows affected (0.00 sec)

Query OK, 1 row affected (0.00 sec)

+------+
| i    |
+------+
|    1 |
+------+
1 rows in set (0.00 sec)

# Term E
$ echo "TXN-START" >> history_list_write.txt

... (sysbench が終わるまで待機)

# Term D
## Simulate Long Transaction End
mysql> rollback;
Query OK, 0 rows affected (0.01 sec)

# Term E
$ echo "TXN-END" >> history_list_write.txt
```

結果は Blog 同様に History List が伸びていきました。
TXN START/END は目安程度に見てください

```bash
$ less history_list_write.txt
...

History list length 31
History list length 592
History list length 1274
History list length 1848
History list length 500
History list length 132
History list length 202
History list length 386
History list length 168
History list length 738
History list length 639
History list length 597
History list length 345
History list length 617
TXN-START
History list length 1286
History list length 1917
History list length 2688
History list length 3365
History list length 4027
History list length 4699
History list length 5345
History list length 6020
History list length 6666
History list length 7372
History list length 8041
History list length 8770
History list length 9520
History list length 10249
History list length 10963
History list length 11626
History list length 12256
History list length 12922
History list length 13600
History list length 14260
History list length 14939
History list length 15619
History list length 16237
History list length 16815
History list length 17494
History list length 18149

...

History list length 52900
History list length 53568
History list length 54343
History list length 55110
History list length 55788
History list length 56471
History list length 57230
History list length 57925
History list length 58017
History list length 58017
History list length 58017
History list length 58017
History list length 58017
History list length 58017
History list length 58017
History list length 58017
History list length 58017
History list length 58017
History list length 58017
History list length 58017
History list length 58017
History list length 58017
History list length 58017
History list length 58017
History list length 58017
History list length 58017
History list length 58017
History list length 58017
History list length 35818
History list length 35818
TXN-END
History list length 35818
History list length 35818
History list length 35818
History list length 35818
History list length 0
History list length 0
```

### ReadOnly Long Trx
今度は Long Transaction を Simulate する際に書き込みを行わないことにしてみます。

```bash
# Term A
## mysql
$ docker-compose up

# Term B
## Watch History List
$ watch -n1 'mysql -h127.0.0.1 -uroot -proot -e "show engine innodb status\G" | grep "History list length" >> history_list_read.txt'

# Term C
## Write Query by sysbench
$ conn="--db-driver=mysql --mysql-host=127.0.0.1 --mysql-user=root --mysql-password=root --mysql-db=sbtest"
$ test="/usr/local/Cellar/sysbench/1.0.19/share/sysbench/tests/include/oltp_legacy/oltp.lua"
$ sysbench $conn $test \
    --num-threads=16 --max-requests=0 --max-time=120 --oltp-table-size=1000000 \
    --oltp-test-mode=complex --oltp-point-selects=0 --oltp-simple-ranges=0 --oltp-sum-ranges=0 \
    --oltp-order-ranges=0 --oltp-distinct-ranges=0 --oltp-index-updates=1 --oltp-non-index-updates=0 \
    run

# Term D
## Simulate Long Transaction Start
mysql> begin; select * from a;
Query OK, 0 rows affected (0.00 sec)

+------+
| i    |
+------+
|    1 |
+------+
1 rows in set (0.00 sec)

# Term E
$ echo "TXN-START" >> history_list_read.txt

... (sysbench が終わるまで待機)

# Term D
## Simulate Long Transaction End
mysql> rollback;
Query OK, 0 rows affected (0.01 sec)

# Term E
$ echo "TXN-END" >> history_list_read.txt
```

結果は先程同様で History List が育ちます。
まぁ ReadOnly かどうかは Commit/Rollback するまで確定しないので同じ挙動になるのは当然な気もしますが。
```bash
$ less history_list_read.txt
...

History list length 371
History list length 345
History list length 13
History list length 282
History list length 218
History list length 338
History list length 82
History list length 197
History list length 427
History list length 168
History list length 353
History list length 499
TXN-START
History list length 1153
History list length 1803
History list length 2453
History list length 3085
History list length 3812
History list length 4526
History list length 5208
History list length 5911
History list length 6561
History list length 7198
History list length 7956
History list length 8729
History list length 9429
History list length 10089
History list length 10835
History list length 11518
History list length 11704
History list length 12382
History list length 13138
History list length 13777
History list length 14486
History list length 15173
History list length 15859
History list length 16565
History list length 17242
History list length 17942
History list length 18572

...

History list length 49672
History list length 50338
History list length 51021
History list length 51643
History list length 52163
History list length 52410
History list length 52726
History list length 52726
History list length 52726
History list length 52726
History list length 52726
History list length 52726
History list length 34127
History list length 34127
TXN-END
History list length 34127
History list length 34127
History list length 34127
History list length 6765
History list length 0
History list length 0
```

### ReadCommitted の場合
Isolation Level を変えると解消されるかも確認しておきます。

```bash
# Term A
## my.cnf を変更しておく
$ docker-compose up

# Term B
## Watch History List
$ watch -n1 'mysql -h127.0.0.1 -uroot -proot -e "show engine innodb status\G" | grep "History list length" >> history_list_rc.txt'

# Term C
## Write Query by sysbench
$ conn="--db-driver=mysql --mysql-host=127.0.0.1 --mysql-user=root --mysql-password=root --mysql-db=sbtest"
$ test="/usr/local/Cellar/sysbench/1.0.19/share/sysbench/tests/include/oltp_legacy/oltp.lua"
$ sysbench $conn $test \
    --num-threads=16 --max-requests=0 --max-time=120 --oltp-table-size=1000000 \
    --oltp-test-mode=complex --oltp-point-selects=0 --oltp-simple-ranges=0 --oltp-sum-ranges=0 \
    --oltp-order-ranges=0 --oltp-distinct-ranges=0 --oltp-index-updates=1 --oltp-non-index-updates=0 \
    run

# Term D
## Change Isolation Level
mysql> set session transaction isolation level READ COMMITTED;
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like 'tx_isolation';
+---------------+----------------+
| Variable_name | Value          |
+---------------+----------------+
| tx_isolation  | READ-COMMITTED |
+---------------+----------------+
1 row in set (0.01 sec)

## Simulate Long Transaction Start
mysql> begin; insert into a values(1); select * from a;
Query OK, 0 rows affected (0.00 sec)

Query OK, 1 row affected (0.00 sec)

+------+
| i    |
+------+
|    1 |
+------+
1 rows in set (0.00 sec)

# Term E
$ echo "TXN-START" >> history_list_rc.txt

... (sysbench が終わるまで待機)

# Term D
## Simulate Long Transaction End
mysql> rollback;
Query OK, 0 rows affected (0.01 sec)

# Term E
$ echo "TXN-END" >> history_list_rc.txt
```

結果は想定通り History List が育ちませんでした。
```bash
$ less history_list_rc.txt
...

History list length 109
History list length 40
History list length 97
History list length 81
History list length 10
History list length 108
History list length 96
History list length 68
History list length 145
TXN-START
History list length 233
History list length 81
History list length 60
History list length 248
History list length 15
History list length 12
History list length 161
History list length 178
History list length 178
History list length 100
History list length 23
History list length 106

...

History list length 180
History list length 166
History list length 113
History list length 170
History list length 159
History list length 180
History list length 186
History list length 14
History list length 14
History list length 14
TXN-END
History list length 14
History list length 14
History list length 14
History list length 14
```
