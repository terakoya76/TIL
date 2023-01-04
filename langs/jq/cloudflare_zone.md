# Cloudflare Zone

## Zone List

```bash
$ curl -X GET "https://api.cloudflare.com/client/v4/zones" \
  -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
  -H "Content-Type: application/json" \
  | jq -rc '.result[] | [.id, .name]'
```

## Record List

```bash
$ zone_id=xxxxx
$ curl -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records" \
  -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
  -H "Content-Type: application/json" \
  | jq -rc '.result[] | [.id, .name]'
```

## Page Rule List

```bash
$ zone_id=xxxxx
$ curl -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/pagerules" \
  -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
  -H "Content-Type: application/json" \
  | jq -rc '.result[]'
```

## Browser Cache TTL Setting

```bash
$ zone_id=xxxxx
$ curl -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/browser_cache_ttl" \
  -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
  -H "Content-Type: application/json" \
  | jq -rc '.result | [.id, .value]'
```
