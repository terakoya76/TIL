## Tips for woking w/ AWS

### ASG
#### Pick up tagged ASG
```bash
$ aws autoscaling describe-auto-scaling-groups | jq '
.AutoScalingGroups[]
  | select(.Tags[].Key == "Stage" and .Tags[].Value == "production")
  | .AutoScalingGroupName
'
```

### RDS
#### List RDS w/ given identifier
```bash
$ DB_PREFIX=<db-prefix>
$ aws rds describe-db-instances  | jq '.DBInstances[].DBInstanceIdentifier' | grep $DB_PREFIX

# when you want to delete them at once
$ aws rds describe-db-instances  | jq '.DBInstances[].DBInstanceIdentifier' | grep $DB_PREFIX | xargs -I{} aws rds delete-db-instance --db-instance-identifier {} --skip-final-snapshot
```

#### Filter RDS Instance by Specific ParameterGroup
```bash
$ aws rds describe-db-instances | jq '.DBInstances[] | select(.DBParameterGroups[].DBParameterGroupName == "<PG>") | .DBInstanceIdentifier'

# change parameter group
$ PG=<parameter-group>
$ DB=<database-identifier>
$ aws rds modify-db-instance --db-instance-identifier $DB --db-parameter-group-name $PG --apply-immediately
# pg status が pending-reboot になるのを確認
$ aws rds describe-db-instances --db-instance-identifier $DB | jq .DBInstances[].DBParameterGroups[]
$ aws rds reboot-db-instance --db-instance-identifier $DB
# pg status が in-sync になるのを確認
$ aws rds describe-db-instances --db-instance-identifier $DB | jq .DBInstances[].DBParameterGroups[]
```

#### Compare ParameterGroup
```bash
$ PG1=<parameter-group1 name>
$ PG2=<parameter-group2 name>
$ QUERY="Parameters[?ParameterValue!='null'].{ParameterName:ParameterName,ParameterValue:ParameterValue}"
$ diff -u <(aws rds describe-db-parameters --db-parameter-group-name $PG1 --query $QUERY | jq -r 'sort_by(.ParameterName)') <(aws rds describe-db-parameters --db-parameter-group-name $PG2 --query $QUERY | jq -r 'sort_by(.ParameterName)')
```
