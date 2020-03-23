# Cloudflare ZTN
## Application List

```bash
$ curl -X GET "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/access/apps" \
  -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
  -H "Content-Type: application/json" \
  | jq -rc '.result[] | select(.type == "self_hosted")'
```

## Tunnel List

```bash
$ curl -X GET "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/cfd_tunnel" \
  -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
  -H "Content-Type: application/json" \
  | jq -rc '.result[] | [.id, .name, .status]'
```

## Tunnel Secret

```bash
$ tid=xxx
$ curl -X GET "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/cfd_tunnel/${tid}/token" \
  -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
  -H "Content-Type: application/json" \
  | jq -rc '.result'
```

## Tunnel Virtual Network List

```bash
$ curl -X GET "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/teamnet/virtual_networks" \
  -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
  -H "Content-Type: application/json" \
  | jq -rc '.result[] | [.id, .name]'
```

## Access Service Token List

```bash
$ curl -X GET "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/access/service_tokens" \
  -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
  -H "Content-Type: application/json" \
  | jq -rc '.result[] | [.id, .name]'
```

## Access Group List

```bash
$ curl -X GET "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/access/groups" \
  -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
  -H "Content-Type: application/json" \
  | jq -rc '.result[] | [.id, .name]'
```
