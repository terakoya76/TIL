# HA
https://www.postgresql.org/docs/current/different-replication-solutions.html

## pgpool-Ⅱ
https://github.com/pgpool/pgpool2

## pg_auto_failover
https://github.com/citusdata/pg_auto_failover

configuration changes in a live system without downtime.

monitoring
* https://pg-auto-failover.readthedocs.io/en/master/faq.html#the-monitor-is-a-spof-in-pg-auto-failover-design-how-should-we-handle-that

## PAF
https://github.com/ClusterLabs/PAF

PAFはread/write splitに対応できない。dedicated serverを要さない分、`PAF` はインフラ効率が良い。
* https://www.sraoss.co.jp/prod_serv/support/cluster_option/

fencing option
* http://clusterlabs.github.io/PAF/fencing.html

## pg_keeper
https://github.com/MasahikoSawada/pg_keeper

`pg_keeper`ではstandbyの数が制限される。ただ一つあれば十分な気がする。
`pg_keeper`はVIP冗長化はしないので、サービスディスカバリは別途対応が必要。

## repmgr
https://github.com/EnterpriseDB/repmgr

custom hook
* https://repmgr.org/docs/current/event-notifications.html

## patroni
https://github.com/zalando/patroni
