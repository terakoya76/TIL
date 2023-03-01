# Curl

## Get Status Code
```bash
$ host=example.com
$ curl -LI ${host} -o /dev/null -w '%{http_code}\n' -s
200
```

## ProxyProtocol
```bash
$ host=example.com
$ curl -I ${host} --haproxy-protocol
```

## Access HTTPS via IP
```bash
$ host=example.com
$ proxy=1.2.3.4
curl -I --resolve ${host}:443:${proxy} https://${host}
```

## Basic Auth
```bash
$ host=example.com
$ username=xx
$ password=yy
curl -I --basic -u ${username}:${password} ${host}
```

## HTTP/2
```bash
$ curl -I --http2 https://http2bin.org/get
```
