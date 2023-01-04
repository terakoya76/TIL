# Check OS

```bash
cat /etc/*-release | grep -w NAME | cut -d= -f2 | tr -d '"'
```
