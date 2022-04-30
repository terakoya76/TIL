# pg_pool2
## Standard Config
https://www.pgpool.net/docs/latest/ja/html/example-cluster.html

## Status
```
postgres=# SHOW POOL_NODES;
 node_id |  hostname   | port | status | lb_weight |  role  | select_cnt | load_balance_node | replication_delay | replication_state | replication_sync_state | last_status_change
---------+-------------+------+--------+-----------+--------+------------+-------------------+-------------------+-------------------+------------------------+---------------------
 0       | 192.168.0.0 | 5432 | down   | 0.500000  | slave  | 0          | false             | 0                 |                   |                        | 2022-04-16 23:43:45
 1       | 192.168.0.1 | 5432 | up     | 0.500000  | master | 0          | true              | 0                 |                   |                        | 2022-04-16 23:43:45
(2 rows)
```

Connection Pool 変数一覧
```
SHOW POOL_STATUS;
```

Connection Pool 一覧
```
SHOW POOL_POOLS;
```

## Health Check
https://www.pgpool.net/docs/42/ja/html/runtime-config-health-check.html

watchdog
* https://www.pgpool.net/docs/42/ja/html/runtime-watchdog-config.html

## Failover
config
* https://www.pgpool.net/docs/42/ja/html/runtime-config-failover.html

health check
* https://www.pgpool.net/docs/42/ja/html/runtime-config-health-check.html

failover.sh
* https://git.postgresql.org/gitweb/?p=pgpool2.git;a=blob_plain;f=src/sample/scripts/failover.sh.sample;hb=refs/heads/V4_2_STABLE

rejoin.sh
* https://git.postgresql.org/gitweb/?p=pgpool2.git;a=blob_plain;f=src/sample/scripts/follow_primary.sh.sample;hb=refs/heads/V4_2_STABLE
