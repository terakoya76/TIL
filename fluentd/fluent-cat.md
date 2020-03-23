# fluent-cat

Install td-agent
```bash
$ curl -L https://toolbelt.treasuredata.com/sh/install-ubuntu-jammy-td-agent4.sh | sh
```

Then echo json
```bash
$ echo '{"foo":"bar"}' | /opt/td-agent/embedded/bin/fluent-cat my.tag
```
