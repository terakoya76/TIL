# iptables memo
Ref: http://www.asahi-net.or.jp/~aa4t-nngk/ipttut/output/ipttut_all.html

## Summary
Ref: https://christina04.hatenablog.com/entry/iptables-outline

## Chain Type
| Chain Type        | Description                                                                                |
|-------------|--------------------------------------------------------------------------------------------|
| INPUT       | 入力（受信）に対するチェイン                                                               |
| OUTPUT      | 出力（送信）に対するチェイン                                                               |
| FORWARD     | フォアード（転送）に対するチェイン                                                         |
| PREROUTING  | 受信時に宛先アドレスを変換するチェイン。タイミングとしてはfilterで適用されるルールより手前 |
| POSTROUTING | 送信時に送信元アドレスを変換するチェイン。これもfilterの後でパケットが送信される直前       |


| Table          | Applicable Chain Type                           | Description                                                                                                                                                                                                                  |
|----------------|-------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| filterテーブル | INPUT, OUTPUT, FORWARD                          | パケットの通過や遮断といった制御をします。                                                                                                                                                                                   |
| natテーブル    | POSTROUTING, PREROUTING, OUTPUT                 | 送信先や送信元といったパケットの中身を書き換える際に利用します。各通信をローカルネットワーク上のサーバへ振り分けるルーターとして機能させることができます。                                                                  |
| mangleテーブル | POSTROUTING, PREROUTING, INPUT, OUTPUT, FORWARD | TOS（Type Of Service）フィールド等の値を書き換えます。TOSはパケット処理の優先度付けを行い、通信品質を制御する際に利用されます。また特定の通信マークを置き換える事もできます。                                                |
| Rawテーブル    | PREROUTING、OUTPUT                              | mangleテーブルのように特定のパケットにマークを付けることですが、Rawテーブルでは追跡を除外するようマークを付けます。つまり、特定の通信をファイアウォールで処理せずに他の機材へ通したりといった経路制御する場合に利用します。 |

## Command
Ref
* http://web.mit.edu/rhel-doc/4/RH-DOCS/rhel-rg-ja-4/s1-iptables-options.html
* https://linuxjf.osdn.jp/JFdocs/NAT-HOWTO-6.html

| Command              | Description                                                           |
|----------------------|-----------------------------------------------------------------------|
| -A（--append）       | 指定チェインに1つ以上の新しいルールを追加                             |
| -C（--check）        | 指定したチェーンに追加する前に特定の規則をチェックする                |
| -D（--delete）       | 指定チェインから1つ以上のルールを削除                                 |
| -I（--insert）       | 指定したチェーンにルール番号を指定してルールを挿入する。              |
| -L（--list）         | コマンドの後で指定するチェーン内にあるすべての規則を一覧表示する      |
| -N（--new-chain）    | 新しいユーザー定義チェインを作成                                      |
| -P（--policy）       | 指定チェインのポリシーを指定したターゲットに設定                      |
| -R（--replace）      | 指定されたチェーンの規則を置き換えます                                |
| -X（--delete-chain） | 指定ユーザー定義チェインを削除                                        |
| -Z                   | テーブルについてすべてのチェーンのバイトとパケットカウンタを 0 にする |

parameter
| Parameter            | Description                                                                                         |
|----------------------|-----------------------------------------------------------------------------------------------------|
| -s (--source)        | パケットの送信元を指定。特定のIP（192.168.0.1）やネットワーク空間（192.168.0.0/24）を指定する。     |
| -d (--destination)   | パケットの宛先を指定。指定方法は-sと同じ。                                                          |
| -p (--protocol)      | チェックされるパケットのプロトコル。 指定できるプロトコルは tcp,udp,icmp,all のいずれか1つか数値。 |
| -i (--in-interface)  | パケットを受信することになるインターフェース名。eth0、eth1など。                                    |
| -o (--out-interface) | 送信先インターフェース名を指定。                                                                    |
| -j (--jump)          | ターゲット（ACCEPT、DROP、REJECT）を指定                                                            |
| -m（--match）        | 使用したい比較オプションモジュールを指定する                                                        |

NAT Table 一覧確認
```bash
$ sudo iptables -t nat -L

# counter 表示
$ sudo iptables -t nat -L -v
```

DNAT
```bash
$ sudo iptables -t nat -A PREROUTING -d 10.0.0.8 -j DNAT --to-destination 10.0.0.9
```

SNAT
```bash
$ sudo iptables -t nat -A POSTROUTING -d 10.0.0.8 -j SNAT --to-source 10.0.0.9
```

Connection Mangle
```bash
$ sudo iptables -t mangle -A PREROUTING -j CONNMARK --restore-mark
$ sudo iptables -t mangle -A PREROUTING -i eth0 -j MARK --set-mark 10
$ sudo iptables -t mangle -A PREROUTING -j CONNMARK --save-mark
```

Rule 削除
```bash
$ sudo iptables -t nat -L --line-numbers
$ sudo iptables -t nat -D PREROUTING 1
```

## User Defined Chain
```bash
# 新規 Chain の追加
$ iptables -N dropchain
# dropchain は Packet を drop する
$ iptables -A dropchain -j DROP
# 80番への incoming traffic は dropchain に飛ばす（drop する）
$ iptables -A INPUT --dport 80 -j dropchain
```

### Logging Drop Packets
input packet
```bash
$ iptables -N LOGGING
$ iptables -A INPUT -j LOGGING
$ iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 4
$ iptables -A LOGGING -j DROP
```

output packet
```bash
$ iptables -N LOGGING
$ iptables -A OUTPUT -j LOGGING
$ iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 4
$ iptables -A LOGGING -j DROP
```

## Matching Module
| Module    | Description                                                                                                                   |
|-----------|-------------------------------------------------------------------------------------------------------------------------------|
| addrtype  | パケットのアドレスタイプに基づいたマッチを行うモジュール                                                                      |
| comment   | iptablesのルールにコメントをつけるモジュール                                                                                  |
| connlimit | 同時接続数を制御するためのモジュール                                                                                          |
| icmp      | ICMPパケットの type/code に基づいてパケットをフィルタリングするモジュール                                                     |
| length    | IPパケット長に基づいてパケットをフィルタリングするモジュール                                                                  |
| mac       | MACアドレスに基づいてパケットをフィルタリングするモジュール。PREROUTING,FORWARD,INPUT の3つのチェインに対して使うことができる |
| set       | ipsetコマンドで作成したセットに基づいてパケットをフィルタリングするモジュール                                                 |
| time      | 日時に基づいてパケットをフィルタリングするモジュール                                                                          |

