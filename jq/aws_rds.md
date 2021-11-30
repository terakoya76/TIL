## Tips for woking w/ AWS RDS
### List RDS w/ given identifier
```bash
$ DB_PREFIX=<db-prefix>
$ aws rds describe-db-instances  | jq '.DBInstances[].DBInstanceIdentifier' | grep ${DB_PREFIX}

# when you want to delete them at once
$ aws rds describe-db-instances  | jq '.DBInstances[].DBInstanceIdentifier' | grep ${DB_PREFIX} | xargs -I{} aws rds delete-db-instance --db-instance-identifier {} --skip-final-snapshot
```

### Filter RDS Instance by Specific ParameterGroup
instance
```bash
$ aws rds describe-db-instances | jq --arg PG ${PG} '.DBInstances[] | select(.DBParameterGroups[].DBParameterGroupName == $PG) | .DBInstanceIdentifier'
$ aws rds describe-db-clusters | jq --arg PG ${PG} '.DBClusters[] | select(.DBClusterParameterGroup == $PG) | .DBClusterIdentifier'

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

### Compare ParameterGroup
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

### Check Instance Class Stats
```bash
# 一覧
$ aws rds describe-db-instances | jq -c '.DBInstances[] | [.DBInstanceIdentifier, .DBInstanceClass]'

# instance class ごとの個数
$ aws rds describe-db-instances \
| jq -rc '.DBInstances | group_by(.Engine, .DBInstanceClass, .MultiAZ)[] | [.[0].Engine, .[0].DBInstanceClass, .[0].MultiAZ, length] | @csv'

# Instance Class ごとに一覧
$ aws rds describe-db-instances |  jq -c '.DBInstances[] | select(.DBInstanceClass == "db.m4.large") | [.DBInstanceIdentifier, .DBInstanceClass, .MultiAZ]'

# Instance Class + Stage ごとに一覧
$ aws rds describe-db-instances | jq -c '.DBInstances[] | select(.DBInstanceClass == "db.t2.small") | select(.TagList[] | .Key == "Stage" and .Value == "production") | [.DBInstanceIdentifier, .DBInstanceClass, .MultiAZ]'

# Instance without the specific tag
$ aws rds describe-db-instances | jq -c '.DBInstances[] | select(.TagList | any(.Key == "Project") | not) | [.DBInstanceIdentifier, .DBInstanceClass, .MultiAZ]'
```

### Change Instance Class
```bash
$ BEFORE="db.t2.small"
$ AFTER="db.t3.small"
$ aws rds describe-db-instances \
| jq --arg BEFORE ${BEFORE} -rc '.DBInstances[] | select(.DBInstanceClass == $BEFORE) | select(.TagList[] | .Key == "Stage" and .Value != "production") | .DBInstanceIdentifier' \
| xargs -I{} aws rds modify-db-instance --db-instance-identifier {} --db-instance-class ${AFTER} --apply-immediately

```
