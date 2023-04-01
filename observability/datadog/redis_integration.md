# Redis Integration
Ref: https://www.datadoghq.com/ja/blog/monitor-redis-using-datadog/

情報は `Redis.info` から取得しているっぽい
* https://github.com/DataDog/integrations-core/blob/78310567cd49ca5bddbe7fa93739e1033f7403c7/redisdb/datadog_checks/redisdb/redisdb.py#L193

## Redis info
* https://redis.io/commands/info/

## conf.d
`mysql-integration` などと同様に、values経由でconf.dをconfigmapに記述することで `$HOME/conf.d` 下へ配置される
Ref: https://github.com/DataDog/integrations-core/blob/master/redisdb/datadog_checks/redisdb/data/conf.yaml.example

values example
```yaml
datadog:
  datadog:
    apmEnabled: false
  daemonset:
    useHostPort: false
  clusterAgent:
    confd:
      redisdb.yaml: |-
        cluster_check: true
        init_config:
        instances:
          - host: test-redis.xxx.yyy.001.apne1.cache.amazonaws.com
            port: 6379
            tags:
              - instance:test-redis
```

## Monitor Setting
### datadog terraform provider
```hcl
resource "datadog_monitor" "redis_net_rejected" {
  name  = "redis_net_rejected"
  type  = "metric alert"
  query = "avg(last_1m):avg:redis.net.rejected{*} by {instance} > 0.1"
  thresholds = {
    "critical" = "0.1"
  }

  message = <<EOF
maxclients 制限のために redis への接続が拒否されました
EOF
}
```

### Post custom metrics for testing
```bash
$ pip3 install datadog
$ dog metric post --tags instance:test-redis redis.net.rejected 10
```
