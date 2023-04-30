# kubeseal

Get Certificate
```bash
ns=sealed-secrets
deploy=sealed-secrets
kubeseal --controller-name=${deploy} --controller-namespace=${ns} --fetch-cert -w ./publickey.pem
```

Encrypt
```bash
kubeseal --format=yaml --cert=./publickey-cert.pem < secret.yaml > sealed-secret.yaml
```
