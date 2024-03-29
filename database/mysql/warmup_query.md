# Warmup MySQL

passwordをclient側の設定ファイルに記載
```bash
$ vi .my.cnf
$ cat .my.cnf
[client]
user=hoge
password=fuga
```

読みたいテーブルのcountを擬似的に確認（countは重すぎる場合）
```bash
$ DB=testdb
$ TABLE=fuga
$ mysql -h$HOST -u$USER -e"SELECT 1 FROM $DB.$TABLE;"
+------------+
| max(id)    |
+------------+
| 793586268 |
+------------+
1 row in set (0.00 sec)
```

適当数分割してquery
```bash
$ MAX=800000000
$ SPLIT=20
$ ITE=$(($MAX/$SPLIT))

# id range
$ for i in `seq 1 $SPLIT`
do
echo "$((($i-1) * $ITE + 1)) $(($i * $ITE))" | awk '{print $1 " and " $2}'
done

# query
$ for i in `seq 1 $SPLIT`
do
echo "$((($i-1) * $ITE + 1)) $(($i * $ITE))" \
| awk -v db=$DB -v tbl=$TBL '{print "SELECT 1 FROM " db "." tbl " WHERE id BETWEEN " $1 " AND " $2 ";"}' \
| xargs -I{} mysql -h$HOST -u$USER -e"{}" > /dev/null
done
```

