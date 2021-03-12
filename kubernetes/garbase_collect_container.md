## GC for Container

Ref: https://kubernetes.io/docs/concepts/cluster-administration/kubelet-garbage-collection/#user-configuration

Containers can potentially be garbage collected before their usefulness has expired.
These containers can contain logs and other data that can be useful for troubleshooting.
A sufficiently large value for maximum-dead-containers-per-container is highly recommended to allow at least 1 dead container to be retained per expected container.
A larger value for maximum-dead-containers is also recommended for a similar reason.
cf. https://github.com/kubernetes/kubernetes/issues/13287

### Image GC
* `image-gc-high-threshold`
  * the percent of disk usage which triggers image garbage collection.
  * Default is 85%.
* `image-gc-low-threshold`
  * the percent of disk usage to which image garbage collection attempts to free.
  * Default is 80%.

### Logs
* `minimum-container-ttl-duration`
  * minimum age for a finished container before it is garbage collected.
  * Default is 0 minute, which means every finished container will be garbage collected.
* `maximum-dead-containers-per-container`
  * maximum number of old instances to be retained per container.
  * Default is 1.
* `maximum-dead-containers`
  * maximum number of old instances of containers to retain globally.
  * Default is -1, which means there is no global limit.

### Configure on EKS
cf. https://aws.amazon.com/jp/premiumsupport/knowledge-center/eks-worker-nodes-image-cache/

