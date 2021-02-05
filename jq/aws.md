## Tips for woking w/ AWS

### EC2
#### Pickup EC2 InstanceID from private IP
```bash
$ aws ec2 describe-instances --filter Name=network-interface.addresses.private-ip-address,Values=${IP} \
| jq -rc '.Reservations[].Instances[] | [.InstanceId, .PrivateIpAddress]'
```

pick up Role tag from private ip
```bash
$ cat ip.txt \
| xargs -I{} aws ec2 describe-instances --filter Name=network-interface.addresses.private-ip-address,Values={} \
| jq -rc '
.Reservations[].Instances[] as $is
  | [($is.Tags[] | select(.Key == "Role") | .Value), $is.PrivateIpAddress]
'
```

#### Pick up tagged ASG
```bash
$ KEY=<key-name>
$ VALUE=<value-name>
$ aws autoscaling describe-auto-scaling-groups | jq --arg KEY ${KEY} --arg VALUE ${VALUE} '
.AutoScalingGroups[]
  | select(.Tags[].Key == $KEY and .Tags[].Value == $VALUE)
  | .AutoScalingGroupName
'
```

#### Pickup named ASG
```bash
$ NAME=<name>
$ aws autoscaling describe-auto-scaling-groups | jq --arg NAME ${NAME} '
.AutoScalingGroups[]
  | select(.AutoScalingGroupName == $NAME)
'
```

#### Pick up tagged Instances
```bash
$ KEY=<key-name>
$ VALUE=<value-name>
$ aws ec2 describe-instances --filter Name=tag:${KEY},Values=${VALUE} \
| jq -rc .Reservations[].Instances[]

# extrace summary
$ aws ec2 describe-instances --filter Name=tag:${KEY},Values=${VALUE} \
| jq -rc '.Reservations[].Instances[] | [.InstanceId, .LaunchTime, .State.Name, .NetworkInterfaces[].PrivateIpAddress]'
```

#### Pickup Instance Summary From ASG Name
```bash
$ NAME=<asg-name>

$ aws autoscaling describe-auto-scaling-groups | jq -cr --arg NAME ${NAME} '
.AutoScalingGroups[]
  | select(.AutoScalingGroupName == $NAME)
  | .Instances[]
  | [.InstanceId, .InstanceType, .AvailabilityZone, .HealthStatus]
'

# only instance id
$ aws autoscaling describe-auto-scaling-groups | jq -cr --arg NAME ${NAME} '
.AutoScalingGroups[]
  | select(.AutoScalingGroupName == $NAME)
  | .Instances[].InstanceId
'
```

### EKS
#### List Cluster w/ given version
```bash
$ VER=<version>
$ aws eks list-clusters \
| jq -r ".clusters[]" \
| xargs -I{} aws eks describe-cluster --name {} \
| jq -rc --arg VER ${VER} 'select(.cluster.version == $VER) | [.cluster.name, .cluster.version]'
```

### RDS
#### List RDS w/ given identifier
```bash
$ DB_PREFIX=<db-prefix>
$ aws rds describe-db-instances  | jq '.DBInstances[].DBInstanceIdentifier' | grep ${DB_PREFIX}

# when you want to delete them at once
$ aws rds describe-db-instances  | jq '.DBInstances[].DBInstanceIdentifier' | grep ${DB_PREFIX} | xargs -I{} aws rds delete-db-instance --db-instance-identifier {} --skip-final-snapshot
```

#### Filter RDS Instance by Specific ParameterGroup
instance
```bash
$ aws rds describe-db-instances | jq --arg PG ${PG} '.DBInstances[] | select(.DBParameterGroups[].DBParameterGroupName == $PG) | .DBInstanceIdentifier'

# change parameter group
$ PG=<parameter-group>
$ DB=<database-identifier>
$ aws rds modify-db-instance --db-instance-identifier ${DB} --db-parameter-group-name ${PG} --apply-immediately

# pg status が pending-reboot になるのを確認
$ aws rds describe-db-instances --db-instance-identifier ${DB} | jq .DBInstances[].DBParameterGroups[]
$ aws rds reboot-db-instance --db-instance-identifier ${DB}

# pg status が in-sync になるのを確認
$ aws rds describe-db-instances --db-instance-identifier ${DB} | jq .DBInstances[].DBParameterGroups[]
```

cluster
```bash
$ aws rds describe-db-clusters | jq --arg CPG ${CPG} '.DBClusters[] | select(.DBClusterParameterGroup == $CPG) | .DBClusterIdentifier'
```

#### Compare ParameterGroup
```bash
$ PG1=<parameter-group1 name>
$ PG2=<parameter-group2 name>
$ QUERY="Parameters[?ParameterValue!='null'].{ParameterName:ParameterName,ParameterValue:ParameterValue}"
$ diff -u <(aws rds describe-db-parameters --db-parameter-group-name ${PG1} --query ${QUERY} | jq -r 'sort_by(.ParameterName)') <(aws rds describe-db-parameters --db-parameter-group-name ${PG2} --query ${QUERY} | jq -r 'sort_by(.ParameterName)')

$ CPG1=<cluster-parameter-group1 name>
$ CPG2=<cluster-parameter-group2 name>
$ QUERY="Parameters[?ParameterValue!='null'].{ParameterName:ParameterName,ParameterValue:ParameterValue}"
$ diff -u <(aws rds describe-db-cluster-parameters --db-cluster-parameter-group-name ${CPG1} --query ${QUERY} | jq -r 'sort_by(.ParameterName)') <(aws rds describe-db-cluster-parameters --db-cluster-parameter-group-name ${CPG2} --query ${QUERY} | jq -r 'sort_by(.ParameterName)')
```

### Route53
#### List Target Endpoints backed by Name
```bash
$ ZID=<hosted_zone_id>
$ Name=<host name>
$ aws route53 list-resource-record-sets --hosted-zone-id ${ZID} | jq --arg Name ${Name} '.ResourceRecordSets[] | select(.Name == $Name) | .ResourceRecords[]'
```

