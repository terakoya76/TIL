# Dual Master Replication

## Infinite Loop
Ref: https://www.percona.com/blog/2011/10/10/infinite-replication-loop/

`--replicate-same-server-id` が無効の場合、slave はそれ自身の server ID を持つ binlog event をスキップする。
* slave I/O thread は relay log に書き込まない
* `--log-slave-updates` が使用されている場合は有効化できない
* https://dev.mysql.com/doc/refman/5.6/ja/replication-options-slave.html

Dual Master Topology において、いずれかの Master server ID と異なる server ID によって記録された binlog を replay すると無限ループが発生してしまう
