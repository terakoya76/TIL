## Helm upgrade failed conflict
Ref: https://github.com/helm/helm/issues/6031

```bash
UPGRADE FAILED
Error: kind Service with the name "XXXXXXXXXXXX" already exists in the cluster and wasn't defined in the previous release. Before upgrading, please either delete the resource from the cluster or remove it from the chart
```

```bash
# rollback to previous success version
$ helm tiller run -- helm rollback <release-name> 0

$ helm tiller run -- helm upgrade <release-name> .
```
