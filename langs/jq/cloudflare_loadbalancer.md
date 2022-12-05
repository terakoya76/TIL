# Cloudflare Loadbalancer

## Pool Detail
```bash
$ pool_id=xxxxx
$ curl -X GET "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/load_balancers/pools/${pool_id}" \
  -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
  -H "Content-Type: application/json" \
  | jq -c '.result.origins[]'

$ curl -X GET "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/load_balancers/pools/${pool_id}" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  | jq -c '.result.origins[]'
```

## Pool Origin Patch
```bash
$ pool_id=xxxxx
$ curl -X PATCH "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/load_balancers/pools/${pool_id}" \
  -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"origins":[{"name":"origin-2","address":"8.8.8.8","enabled":true,"weight":1}]}' \
  | jq -c .result
```

## Pool Add New Oriign
```bash
$ pool_id=xxxxx

$ curl -X GET "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/load_balancers/pools/${pool_id}" \
  -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
  -H "Content-Type: application/json" \
  | jq -r '.result.origins[] | with_entries(select(.key == "name" or .key == "address" or .key == "enabled" or .key == "weight")) | tojson' \
  | jq -sc > current

$ cat > new <<EOF
[{"name": "hoge", "address": "8.8.8.8", "enabled": true, "weight": 1}]
EOF

$ curl -X PATCH "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/load_balancers/pools/${pool_id}" \
  -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \ 
  -H "Content-Type: application/json" \
  -d "{\"origins\":$(jq -s add a b)}" \
  | jq .
```
