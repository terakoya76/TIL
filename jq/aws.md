## Tips for woking w/ AWS

### ASG
pick up tagged ASG
```bash
$ aws autoscaling describe-auto-scaling-groups | jq '
.AutoScalingGroups[]
  | select(.Tags[].Key == "Stage" and .Tags[].Value == "production")
  | .AutoScalingGroupName
'
```

### RDS
list RDS w/ given identifier
```bash
$ aws rds describe-db-instances  | jq '.DBInstances[].DBInstanceIdentifier' | grep <db-identifier>

# when you want to delete them at once
$ aws rds describe-db-instances  | jq '.DBInstances[].DBInstanceIdentifier' | grep <db-identifier> | xargs -I{} aws rds delete-db-instance --db-instance-identifier {} --skip-final-snapshot
```
