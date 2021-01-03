## Plugins

### Frequently Used Plugin Tips
#### resource-capacity
check node resource capacity
```bash
$ k resource-capacity
NODE                                             CPU REQUESTS   CPU LIMITS    MEMORY REQUESTS   MEMORY LIMITS
*                                                3312m (85%)    2892m (74%)   5518Mi (21%)      11160Mi (42%)
ip-10-0-26-3.ap-northeast-1.compute.internal     1478m (76%)    1168m (60%)   2478Mi (19%)      4826Mi (37%)
ip-10-0-56-225.ap-northeast-1.compute.internal   1834m (95%)    1724m (89%)   3040Mi (23%)      6334Mi (48%)
```

#### iexec
easy to select pod to be execed into
```bash
$ k iexec -A flu
Use the arrow keys to navigate: ↓ ↑ → ←
? Select Pod:
  Namespace: kube-system | Pod: fluentd-8696t
  Namespace: kube-system | Pod: ▸ fluentd-kbpsn
```

#### get-all
list all obj including objs which are not printed by `k get all`
```bash
$ k get-all
NAME                                                                                                        NAMESPACE                    AGE
componentstatus/controller-manager                                                                                                       <unknown>
componentstatus/scheduler                                                                                                                <unknown>
componentstatus/etcd-0                                                                                                                   <unknown>
configmap/cloudwatch-metrics-exporter-env                                                                   cloudwatch-metrics-exporter  224d
(snip)
```

#### images
```bash
$ k images
[Summary]: 1 namespaces, 2 pods, 2 containers and 1 different images
+-----------------+---------------+------------------------------+
|     PodName     | ContainerName |        ContainerImage        |
+-----------------+---------------+------------------------------+
| ssm-agent-7mvs8 | ssm-agent     | xxxxx/aws-ssm-agent:v1.0.0   |
+-----------------+               +                              +
| ssm-agent-qr2bt |               |                              |
+-----------------+---------------+------------------------------+
```

#### tree
```bash
$ k tree daemonsets.v1.apps fluentd -n kube-system
NAMESPACE    NAME                                       READY  REASON  AGE
kube-system  DaemonSet/fluentd                          -              304d
kube-system  ├─ControllerRevision/fluentd-5475789648  -              212d
kube-system  ├─ControllerRevision/fluentd-54d7c97448  -              212d
kube-system  ├─ControllerRevision/fluentd-5db89694c6  -              27d
kube-system  ├─ControllerRevision/fluentd-659c8cf5bb  -              162d
kube-system  ├─ControllerRevision/fluentd-76649656f4  -              304d
kube-system  ├─ControllerRevision/fluentd-76c5c65945  -              57d
kube-system  ├─ControllerRevision/fluentd-867d97b8db  -              196d
kube-system  ├─ControllerRevision/fluentd-86d6b44458  -              196d
kube-system  ├─ControllerRevision/fluentd-cd58c79bb   -              212d
kube-system  ├─ControllerRevision/fluentd-dd4669cf    -              141d
kube-system  ├─Pod/fluentd-8696t                      True           27d
kube-system  └─Pod/fluentd-kbpsn                      True           27d
```

#### status
```bash
$ k status ds fluentd -n kube-system

DaemonSet/fluentd -n kube-system, created 10mo ago, gen:13
  desired:2, current:2, available:2, ready:2, updated:2
```

#### neat
```bash
$ k get cm coredns -n kube-system -o yaml | k neat
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health {
          lameduck 15s
        }
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          upstream
          fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
kind: ConfigMap
metadata:
  labels:
    eks.amazonaws.com/component: coredns
    k8s-app: kube-dns
  name: coredns
  namespace: kube-system
```

#### trace
`kprobes/kretprobes, tracepoints, software, hardware, profile events` は node に対して。
`uprobe/uretprobe, USDT events` は pod に対して trace を掛けるのが推奨される。
```bash
$ k trace run ip-10-1-10-231.ap-northeast-1.compute.internal -e "tracepoint:syscalls:sys_enter_* { @[probe] = count(); }"
```

header file が見つからないケースは追加の依存を node に入れる必要あり
```bash
$ k logs kubectl-trace-9a2302ae-5103-11eb-9be5-acde48001122-x7d62
if your program has maps to print, send a SIGINT using Ctrl-C, if you want to interrupt the execution send SIGINT two times
/bpftrace/include/clang_workarounds.h:14:10: fatal error: 'linux/types.h' file not found
exit status 1

# Amazon Linux 2 node
sudo yum install kernel-devel-$(uname -r)
# Debian 10 node
sudo apt install -y linux-headers-amd64
# Ubuntu 20.10 node
sudo apt install -y apt install linux-headers-5.8.0-26-generic
```
* https://github.com/iovisor/kubectl-trace/issues/76

#### advise-psp
check recommended psp based on our cluster
```bash
$ k advise-psp inspect --report | jq .
```
