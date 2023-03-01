# lxcfs

## Summary
Ref: https://github.com/lxc/lxcfs

LXCFSは、Linuxコンテナをより仮想マシンに近い感覚で使えるようにすることを意図して書かれた、小さなFUSEファイルシステムです。
* LXCのサイドプロジェクトとして始まったが、どのランタイムでも使用可能です。

Ref: https://gihyo.jp/admin/serial/01/linux_containers/0033

LXCFSはホスト上で実行され、下記の機能を提供する
* コンテナ向けの `cgroupfs` ツリーの提供
* コンテナ向けの `/proc` 以下のファイルの提供

cgroupfsの提供
* bind mountされた `cgroupfs` ツリーが、コンテナ内から参照された際には、そのコンテナに関係する `cgroup` のみを見せるように提供します。
* これにより `systemd` などの `cgroupfs` ツリーが必要なソフトウェアに対して、実際に `cgroupfs` をmountしたときのようなツリーを見せられます。

procfsの提供
* これまでもPIDやmount名前空間により、コンテナ向けの `/proc` が提供できました。
  * しかし、リソースの状態を提供するようなファイルの中身はホストと同じ値が提供されていました。
  * この背景から、メモリの消費状況を表示するためにリソース表示系のコマンドを使った場合、ホスト上で実行した際と同じ値がそのまま表示されていました。
  * そのため、コンテナ内で消費されているリソースをモニタリングする際は、ホスト上で `cgroup` が提供するファイルから値を読み取る必要がありました。
* LXCFSを使うと、LXCFSがコンテナの `cgroup` から値を読み取り、コンテナ内で `/proc` 以下の対象となるファイルが読まれた場合に、コンテナごとの値を表示します。
  * この機能により、コンテナ内でもホスト上と同じようにコマンドを実行して、コンテナ内のリソース状態をチェックできます。


## LXCFS to provide container resource visibility on Kubernetes

install and deploy LXCFS on all cluster nodes
```yaml
# the LXCFS FUSE must share the system PID namespace and requires a privilege mode, we have configured the relevant container startup parameters.
#
# https://github.com/denverdino/lxcfs-admission-webhook/blob/master/deployment/lxcfs-daemonset.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: lxcfs
  labels:
    app: lxcfs
spec:
  selector:
    matchLabels:
      app: lxcfs
  template:
    metadata:
      labels:
        app: lxcfs
    spec:
      hostPID: true
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      containers:
      - name: lxcfs
        image: registry.cn-hangzhou.aliyuncs.com/denverdino/lxcfs:3.1.2
        imagePullPolicy: Always
        securityContext:
          privileged: true
        volumeMounts:
        - name: cgroup
          mountPath: /sys/fs/cgroup
        - name: lxcfs
          mountPath: /var/lib/lxcfs
          mountPropagation: Bidirectional
        - name: usr-local
          mountPath: /usr/local
      volumes:
      - name: cgroup
        hostPath:
          path: /sys/fs/cgroup
      - name: usr-local
        hostPath:
          path: /usr/local
      - name: lxcfs
        hostPath:
          path: /var/lib/lxcfs
          type: DirectoryOrCreate
```

adminssion-Webhook等でpodにlxcfs経由でprocfsをmountする
* https://github.com/denverdino/lxcfs-admission-webhook/blob/653e660654d6cd6035400fb4c0169ac20631c11c/lxcfs.go#L213-L252

各podからprocfsへアクセスできるようになる
```bash
$ kubectl get pod
NAME                                                 READY   STATUS    RESTARTS   AGE
lxcfs-admission-webhook-deployment-f4bdd6f66-5wrlg   1/1     Running   0          8m29s
lxcfs-pqs2d                                          1/1     Running   0          55m
lxcfs-zfh99                                          1/1     Running   0          55m
web-7c5464f6b9-6zxdf                                 1/1     Running   0          8m10s
web-7c5464f6b9-nktff                                 1/1     Running   0          8m10s

$ kubectl exec -ti web-7c5464f6b9-6zxdf sh
# free
             total       used       free     shared    buffers     cached
Mem:        262144       2744     259400          0          0        312
-/+ buffers/cache:       2432     259712
Swap:            0          0          0
```

## Usecase
Debug another pod on Kubernetes
* https://github.com/aylei/kubectl-debug/pull/83
