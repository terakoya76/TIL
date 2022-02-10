# Tips for woking w/ AWS Route53
## List Target Endpoints backed by Name
```bash
$ ZID=<hosted_zone_id>
$ Name=<host name>
$ aws route53 list-resource-record-sets --hosted-zone-id ${ZID} | jq --arg Name ${Name} '.ResourceRecordSets[] | select(.Name == $Name) | .ResourceRecords[]'
```

