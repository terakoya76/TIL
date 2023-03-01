# Log Management for Container stdout/stderr streams
Ref: https://github.com/kubernetes/community/blob/master/contributors/design-proposals/node/kubelet-cri-logging.md

## Current
Log lifecycle and management
> Docker deletes the log files when the container is removed, and a cron-job (or systemd timer-based job) on the node is responsible to rotate the logs (using logrotate).
> To preserve the logs for introspection and debuggability, kubelet keeps the terminated container until the pod object has been deleted from the apiserver.

現段階では `kubectl logs` は `docker logs` を wrap しているだけ
> In the current implementation, kubelet calls docker logs with parameters to return the log content.

Cluster logging support

> In a production cluster, logs are usually collected, aggregated, and shipped to a remote store where advanced analysis/search/archiving functions are supported.
> In kubernetes, the default cluster-addons includes a per-node log collection daemon, fluentd.
> To facilitate the log collection, kubelet creates symbolic links to all the docker containers logs under /var/log/containers with pod and container metadata embedded in the filename.

`/var/log/containers/<pod_name>_<pod_namespace>_<container_name>-<container_id>.log`

> The fluentd daemon watches the /var/log/containers/ directory and extract the metadata associated with the log from the path.
> Note that this integration requires kubelet to know where the container runtime stores the logs, and will not be directly applicable to CRI

## Proposal
requirements
* Provide ways for CRI-compliant runtimes to support all existing logging features, i.e., kubectl logs.
* Allow kubelet to manage the lifecycle of the logs to pave the way for better disk management in the future. This implies that the lifecycle of containers and their logs need to be decoupled.
* Allow log collectors to easily integrate with Kubernetes across different container runtimes while preserving efficient storage and retrieval.

poposal
* Enforce where the container logs should be stored on the host filesystem. Both kubelet and the log collector can interact with the log files directly.
* Ask the runtime to decorate the logs in a format that kubelet understands.
`/var/log/pods/<podUID>/<containerName>_<instance#>.log`

## Log Rotation on EKS
Ref: https://github.com/awslabs/amazon-eks-ami/blob/v20210310/files/docker-daemon.json#L4-L7

docker logging driver option により log rotate している
cf. https://docs.docker.jp/engine/reference/logging/overview.html
* max-size
  * ログが max-size に到達すると、ロールオーバされます（別のファイルに繰り出されます）。
  * 設定できるサイズは、キロバイト(k)、メガバイト(m)、ギガバイト(g) です。
  * 例えば、 --log-opt max-size=50m のように指定します。
  * もし max-size が設定されなければ、ログはロールオーバされません。
* max-file
  * ログが何回ロールオーバされたら破棄するかを指定します。
  * 例えば --log-opt max-file=100 のように指定します。
  * もし max-size が設定されなければ、 max-file は有効ではありません。
