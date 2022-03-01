# Fluentd Logging Driver
Ref: https://docs.docker.com/config/containers/logging/fluentd/

```json
{
  "log-driver": "fluentd",
  "log-opts": {
    "fluentd-address": "fluentdhost:24224",
    "tag": "{{.ID}}"
  }
}
```

Docker CLI
```bash
$ docker container run --rm \
  --name httpd \
  -v `pwd`/httpd-docs-2.4.33.en:/usr/local/apache2/htdocs \
  --log-driver=fluentd \
  --log-opt fluentd-address=tcp://172.17.0.2:24224 \
  --log-opt tag=docker.{{.ImageName}}.{{.Name}}.{{.ID}} \
  httpd:2.4.37
```

Other Option
```bash
$ docker run --log-driver=fluentd --log-opt fluentd-address=fluentdhost:24224
$ docker run --log-driver=fluentd --log-opt fluentd-address=tcp://fluentdhost:24224
$ docker run --log-driver=fluentd --log-opt fluentd-address=unix:///path/to/fluentd.sock
```

