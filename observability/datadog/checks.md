# Checks


cluster内の監視はendpointschecks
```
DD_EXTRA_CONFIG_PROVIDERS="kube_endpoints kube_services"
DD_EXTRA_LISTENERS="kube_endpoints kube_services"
```

cluster外の監視はclusterchecks
```bash
DD_EXTRA_CONFIG_PROVIDERS="endpointschecks clusterchecks"
```

## ClusterChecks による Checks
Ref: https://docs.datadoghq.com/ja/agent/cluster_agent/clusterchecks/
```yaml
cluster_check: true
init_config:
instances:
- server: '<PRIVATE_IP_ADDRESS>'
  port: 3306
  user: datadog
  pass: '<YOUR_CHOSEN_PASSWORD>'
```

trouble shooting
```bash
kubectl exec <ClusterAgent Pod> agent clusterchecks
kubectl exec <ClusterAgent Pod> agent status
kubectl exec <ClusterAgent Pod> agent metamap
kubectl exec <ClusterAgent Pod> agent configcheck
```

## Service Annotation による Checks
Ref: https://docs.datadoghq.com/ja/agent/cluster_agent/endpointschecks/

annotation
```yaml
ad.datadoghq.com/endpoints.check_names: '[<インテグレーション名>]'
ad.datadoghq.com/endpoints.init_configs: '[<初期コンフィギュレーション>]'
ad.datadoghq.com/endpoints.instances: '[<インスタンスコンフィギュレーション>]'
ad.datadoghq.com/endpoints.logs: '[<ログコンフィギュレーション>]'
```

trouble shooting
```bash
kubectl exec <対象ノード上の NodeAgent Pod> agent configcheck
kubectl exec <対象ノード上の NodeAgent Pod> agent status
```
