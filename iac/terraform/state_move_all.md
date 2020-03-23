# State mv all

```bash
# NG
$ tf state list | grep xxx | xargs -0 -I{} terraform state rm '{}'
╷
│ Error: Invalid character
│
│   on  line 2:
│   (source code not available)
│
│ Expected an attribute access or an index operator.

# OK
# cf. https://stackoverflow.com/questions/67928184/xargs-and-terraform-state-rm
$ tf state list | grep roles | xargs -d'\n' -I{} terraform state rm '{}'
```
