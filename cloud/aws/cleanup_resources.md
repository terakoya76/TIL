# Cleanup Resources

## AMI
```bash
active_image_ids=$(comm -12 \
  <(aws ec2 describe-images \
    --no-cli-auto-prompt \
    --owners "${AWS_ACCOUNT_ID}" \
    | jq -r .Images[].ImageId \
    | sort | uniq) \
  <(aws ec2 describe-instances \
    --no-cli-auto-prompt \
    | jq -r '.Reservations[].Instances[].ImageId' \
    | sort | uniq) \
    | xargs -I{} echo \"{}\")

# EC2 Image Builder 経由の利用中 AMI 一覧
for ent in $(aws ec2 describe-images \
  --no-cli-auto-prompt \
  --image-ids $(echo "${active_image_ids}" | xargs) \
  | jq -rc '.Images[]
    | (.Tags[] | select(.Key == "Ec2ImageBuilderArn") | .Value) as $arn
    | [.ImageId, .CreationDate, $arn]'); do

  id=$(echo "${ent}" | jq -rc .[0])
  ts=$(echo "${ent}" | jq -rc .[1])
  svc=$(echo "${ent}" | jq -rc .[2] | cut -d/ -f2)

  echo "Active AMI: ${id}, ${svc}, ${ts}"

  len=$(aws ec2 describe-images \
    --no-cli-auto-prompt \
    --owners "${AWS_ACCOUNT_ID}" \
    | jq -rc --arg ts "${ts}" --arg svc "${svc}" '.Images[]
      | select(
        .CreationDate < $ts and
        (.Tags[] | select(.Key == "Ec2ImageBuilderArn") | .Value | contains($svc)))
      | .Name' \
    | wc -l)

  drop=$((len - hold))
  if [ $drop -gt 0 ]; then
    aws ec2 describe-images \
      --no-cli-auto-prompt \
      --owners "${AWS_ACCOUNT_ID}" \
      | jq -rc --arg ts "${ts}" --arg svc "${svc}" '.Images
        | sort_by(.CreationDate)
        | .[]
        | select(
          .CreationDate < $ts and
          (.Tags[] | select(.Key == "Ec2ImageBuilderArn") | .Value | contains($svc)))' \
      | jq -r --slurp --arg drop $drop '.
        | limit($drop | tonumber; .[])
        | .ImageId' \
      | xargs -I{} aws deregister-image --image-id "{}"
  else
    echo "There is no stale AMI"
  fi
done
```

## EBS Snapshot
```bash
AWS_ACCOUNT_ID=xxxxxxx
ORPHANED_SNAPSHOT_IDS=$(comm -23 \
  <(aws ec2 describe-snapshots \
    --no-cli-auto-prompt \
    --owner-ids $AWS_ACCOUNT_ID \
    --filters "Name=tag:CreatedBy,Values=EC2 Image Builder" \
    | jq -r .Snapshots[].SnapshotId \
    | sort | uniq) \
  <(aws ec2 describe-images \
    --no-cli-auto-prompt \
    --owners "${AWS_ACCOUNT_ID}" \
    | jq -r '.Images[].BlockDeviceMappings[].Ebs.SnapshotId | select(. != null)' \
    | sort | uniq))

for snapshot_id in $ORPHANED_SNAPSHOT_IDS; do
  aws ec2 delete-snapshot \
    --no-cli-auto-prompt \
    --snapshot-id ${snapshot_id}
done
```
