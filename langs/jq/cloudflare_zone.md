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

## Redirect Rule List

```bash
$ zone_id=xxxxx
$ curl -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/rulesets/phases/http_request_dynamic_redirect/entrypoint" \
  -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
  -H "Content-Type: application/json" \
  | jq -r .result
```

## Transform Rule List

```bash
$ zone_id=xxxxx
# https://api.cloudflare.com/#transform-rules-properties
$ phase=http_response_headers_transform
$ curl -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/rulesets/phases/${phase}/entrypoint" \
  -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
  -H "Content-Type: application/json" \
  | jq -r .result.rules[]
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

