# API

## Infra Alert Condition
```bash
curl -X GET -H "Api-Key: ${key}" "https://infra-api.newrelic.com/v2/alerts/conditions?policy_id=${policy_id}" | jq .
```
