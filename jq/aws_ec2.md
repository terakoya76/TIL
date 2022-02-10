# Tips for woking w/ AWS EC2
## Pickup EC2 InstanceID from private IP
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

## Pick up tagged ASG
```bash
$ KEY=<key-name>
$ VALUE=<value-name>
$ aws autoscaling describe-auto-scaling-groups | jq --arg KEY ${KEY} --arg VALUE ${VALUE} '
.AutoScalingGroups[]
  | select(.Tags[].Key == $KEY and .Tags[].Value == $VALUE)
  | .AutoScalingGroupName
'
```

## Pickup named ASG
```bash
$ NAME=<name>
$ aws autoscaling describe-auto-scaling-groups | jq --arg NAME ${NAME} '
.AutoScalingGroups[]
  | select(.AutoScalingGroupName == $NAME)
'
```

## Pick up tagged Instances
```bash
$ KEY=<key-name>
$ VALUE=<value-name>
$ aws ec2 describe-instances --filter Name=tag:${KEY},Values=${VALUE} \
| jq -rc .Reservations[].Instances[]

# extrace summary
$ aws ec2 describe-instances --filter Name=tag:${KEY},Values=${VALUE} \
| jq -rc '.Reservations[].Instances[] | [.InstanceId, .LaunchTime, .State.Name, .NetworkInterfaces[].PrivateIpAddress]'
```

## Pickup Instance Summary From ASG Name
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

