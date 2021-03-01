## Rand in shellscript

```bash
$ tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 16 | head -n 1
```
