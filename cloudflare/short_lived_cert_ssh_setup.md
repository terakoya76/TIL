# Short-lived certs ssh config
cf. https://developers.cloudflare.com/cloudflare-one/identity/users/short-lived-certificates


```bash
#!/bin/sh

cf_username="terakoya76"

for h in $(curl -X GET "https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/access/apps" \
  -H "X-Auth-Email: ${CF_API_EMAIL}" \
  -H "X-Auth-Key: ${CF_API_KEY}" \
  -H "Content-Type: application/json" \
  | jq -r '.result[] | select(.type == "self_hosted") | .domain'); do

  cat >> res <<EOF
Host ${h}
  User ${cf_username}
  ProxyCommand bash -c '/usr/local/bin/cloudflared access ssh-gen --hostname %h; ssh -tt %r@cfpipe-${h} >&2 <&1'

Host cfpipe-${h}
  HostName ${h}
  ProxyCommand /usr/local/bin/cloudflared access ssh --hostname %h
  IdentityFile ~/.cloudflared/${h}-cf_key
  CertificateFile ~/.cloudflared/${h}-cf_key-cert.pub

EOF

done
```
