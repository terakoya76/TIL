# Tips for working w/ AWS Lambda

## List Lambda
```bash
$ aws lambda list-functions | jq -c '.Functions[] | [.FunctionName, .LastModified]'
```
