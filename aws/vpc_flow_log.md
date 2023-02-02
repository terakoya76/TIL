# VPC Flow Log

format
```
${version} ${account-id} ${interface-id} ${srcaddr} ${dstaddr} ${srcport} ${dstport} ${protocol} ${packets} ${bytes} ${start} ${end} ${action} ${log-status}
```

* `${version}`: VPCフローログのバージョン
* `${account-id}`: AWSアカウントのID
* `${interface-id}`: ネットワークインターフェイスのID
* `${srcaddr}`: 送信元IPアドレス
* `${dstaddr}`: 送信先IPアドレス
* `${srcport}`: 送信元ポート
* `${dstport}`: 送信先ポート
* `${protocol}`: プロトコルの番号
* `${packets}`: パケットの数
* `${bytes}`: バイト数
* `${start}`: 開始時刻(unixtime)
* `${end}`: 終了時刻(unixtime)
* `${action}`: アクション(ACCEPT or REJECT)
* `${log-status}`: ログ(OK or NODATA or SKIPDATA)
