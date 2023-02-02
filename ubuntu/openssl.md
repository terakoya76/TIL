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


is Root Cert?
```bash
# CA:TRUE = Root Cert
# CA:FALSE = Server Cert
openssl x509 -text -noout -in certs/root.pem | grep CA:
                CA:TRUE, pathlen:0
```

verify file
```bash
openssl verify -show_chain -verbose certs/server.pem

# without chain path chain path
openssl verify -show_chain -verbose certs/server.pem
CN = *.my.com
error 20 at 0 depth lookup: unable to get local issuer certificate
error server.pem: verification failed

openssl verify -show_chain -verbose -untrusted certs/root.pem certs/server.pem
```
