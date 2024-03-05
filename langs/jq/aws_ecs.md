# Tips for working w/ AWS ECS

## List ECS
```bash
$ aws ecs list-serviclusters | jq -cr .clusterArns[]

$ CLUSTER_NAME=<cluster-name>
$ aws ecs list-services --cluster ${CLUSTER_NAME} | jq -cr .serviceArns[]
```
