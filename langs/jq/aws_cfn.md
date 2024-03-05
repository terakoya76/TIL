# Tips for working w/ AWS CloudFormation

## List CloudFormation Stacks

```bash
$ aws cloudformation list-stacks | jq -c '.StackSummaries[] | [.StackName, .StackStatus]'
```
