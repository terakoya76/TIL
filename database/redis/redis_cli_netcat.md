# Connect Redis via netcat

```bash
echo -e 'KEYS *' | netcat -w1 localhost 6379
```
