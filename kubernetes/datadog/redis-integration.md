## Redis Integration
Ref: https://www.datadoghq.com/ja/blog/monitor-redis-using-datadog/

情報は `Redis.info` から取得しているっぽい
* https://github.com/DataDog/integrations-core/blob/78310567cd49ca5bddbe7fa93739e1033f7403c7/redisdb/datadog_checks/redisdb/redisdb.py#L193

## Redis info
* https://redis.io/commands/INFO

## conf.d
mysql-integration などと同様に values 経由で conf.d を configmap に記述することで `$HOME/conf.d` 下に配置される
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
