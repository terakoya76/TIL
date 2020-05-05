## Tips for woking w/ AWS

pick up tagged ASG
```bash
$ aws autoscaling describe-auto-scaling-groups | jq '
.AutoScalingGroups[]
  | select(.Tags[].Key == "Stage" and .Tags[].Value == "production")
  | .AutoScalingGroupName
'
```
