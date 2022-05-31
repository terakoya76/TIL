# Curl

## Get Status Code
```bash
$ curl -LI mazgi.com -o /dev/null -w '%{http_code}\n' -s
200
```
