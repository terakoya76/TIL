# Tips for working w/ AWS CloudWatch

## List CloudWatch Logs
```bash
$ aws logs describe-log-groups | jq -cr '.logGroups[] | [.logGroupName, .retentionInDays]'
```
