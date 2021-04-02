## kube-prometheus
Ref: https://github.com/prometheus-operator/kube-prometheus

```bash
$ ghq get https://github.com/prometheus-operator/kube-prometheus
$ kubectl create -f manifests/setup
$ until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
$ kubectl create -f manifests/
$ kubectl -n monitoring port-forward svc/grafana 3000
```
