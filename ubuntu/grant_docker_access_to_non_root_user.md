# Grant docker access to non-root user

Install
cf. https://kinsta.com/jp/blog/install-docker-ubuntu/

```bash
$ curl -fsSL https://get.docker.com -o get-docker.sh
$ sudo sh get-docker.sh
```

Grant
```bash
$ sudo usermod -aG docker $USER
```
