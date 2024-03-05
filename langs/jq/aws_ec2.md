# Tips for woking w/ AWS EC2
## Pickup EC2 Instance ID from private IP
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

## Pickup EC2 Tags from Instance ID
```bash
$ aws ec2 describe-instances --filter Name=instance-id,Values=${ID} \
| jq -rc '.Reservations[].Instances[0].Tags[] | select(.Key == "Stage") | .Value'
```

## Pickup All EC2 Instances
```bash
$ aws ec2 describe-instances | jq -c '.Reservations[].Instances[].Tags[] | select(.Key == "Name")'
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

## Pickup tagged Instances
```bash
$ KEY=<key-name>
$ VALUE=<value-name>
$ aws ec2 describe-instances --no-cli-auto-prompt --filter Name=tag:${KEY},Values=${VALUE} \
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

## Pickup Newly Launched Instance IDs
```bash
name=hoge

old_instance_ids=$(aws --no-cli-auto-prompt \
  autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-name ${name} \
  | jq -c [.AutoScalingGroups[0].Instances[].InstanceId])

new_instance_ids=$(aws --no-cli-auto-prompt \
  autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-name ${name} \
  | jq -c [.AutoScalingGroups[0].Instances[].InstanceId])

merged="{\"old_instance_ids\":${old_instance_ids}, \"new_instance_ids\":${new_instance_ids}}"

echo ${merged} | jq -r '.new_instance_ids - .old_instance_ids | .[]'
```

## Pickup Unused SecurityGroup
```bash
for sg in `aws ec2 describe-security-groups --query 'SecurityGroups[].[join(\`,\`,[GroupId,GroupName])]' --output text`; do
  echo -n "${sg}"
  sg_id=$(echo ${sg} | cut -d ',' -f1)
  sg_name=$(echo ${sg} | cut -d ',' -f2)

  # ENI
  eni=$(aws ec2 describe-network-interfaces --filters Name=group-id,Values=${sg_id} --query 'NetworkInterfaces[]' --output text)
  if [ -n "${eni}" ]; then
    echo -n ",true"
  else
    echo -n ",false"
  fi

  # Launch Configutation
  as=$(aws autoscaling describe-launch-configurations --query "LaunchConfigurations[?contains(SecurityGroups,\`${sg_id}\`)].[LaunchConfigurationName]" --output text)
  if [ -n "${as}" ]; then
    echo -n ",true"
  else
    echo -n ",false"
  fi

  echo ;
done
```
