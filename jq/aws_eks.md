# Tips for woking w/ AWS EKS
## List Cluster w/ given version
```bash
$ VER=<version>
$ aws eks list-clusters \
| jq -r ".clusters[]" \
| xargs -I{} aws eks describe-cluster --name {} \
| jq -rc --arg VER ${VER} 'select(.cluster.version == $VER) | [.cluster.name, .cluster.version]'
```
