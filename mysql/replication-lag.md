## Replication Lag

Ref:
* https://dev.mysql.com/doc/refman/8.0/en/faqs-replication.html#faq-replication-how-compare-replica-date

replication SQL thread が source から読み込んだ event を実行すると、event の timestamp に自分の時間を修正します。
`SHOW PROCESSLIST` の出力の Time 列では、replication SQL thread に表示される秒数は、最後に replication された event の timestamp と replica machine の実時間との間の秒数です。
これを使用して、最後に replicate された event の日付を判断することができます。
replica が1時間 source から切断された後に再接続した場合、`SHOW PROCESSLIST` の replication SQL thread に 3600 のような大きな Time 値がすぐに表示される可能性があることに注意してください。

これは、replica が1時間前の statement を実行しているためです。
