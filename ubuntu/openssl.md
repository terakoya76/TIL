# openssl

## Cert 確認

via connection
```bash
openssl s_client -connect <domain>:443 -showcerts
```

via file
```bash
openssl x509 -text -noout -in ./server.pem
```

check Issuer
```bash
openssl x509 -text -noout -in certs/server.pem | grep -i issuer:
```

Ensure whether Root Cert or not.
```bash
# CA:TRUE = Root Cert
# CA:FALSE = Server Cert
openssl x509 -text -noout -in certs/root.pem | grep CA:
                CA:TRUE, pathlen:0
```

verify file
```bash
openssl verify -show_chain -verbose certs/server.pem

# without chain path
openssl verify -show_chain -verbose certs/server.pem
CN = *.my.com
error 20 at 0 depth lookup: unable to get local issuer certificate
error server.pem: verification failed

openssl verify -show_chain -verbose -untrusted certs/root.pem certs/server.pem
```

## Create Self-Signed Cert

```bash
$ openssl req -new -x509 \
  -out server.crt \
  -newkey rsa:2048 -keyout server.key \
  -days 3650 \
  -sha256 \
  -subj "/C=JP/CN=localhost" -addext "subjectAltName = DNS:localhost, IP:127.0.0.1" \
  -nodes

# usable from client
$ sudo cp server.crt /usr/local/share/ca-certificates/localhost.crt
$ sudo update-ca-certificates
```
