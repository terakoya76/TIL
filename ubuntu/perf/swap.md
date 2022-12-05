# Swap Usage

Swapを使っているプロセスと使用量を使ってる順に表示
```bash
$ grep VmSwap /proc/*/status | sort -k 2 -nr
```

Swapを使っているプロセス
```bash
$ grep VmSwap /proc/*/status | sort -k 2 -nr | cut -d"/" -f3 | grep -e '^[0-9]*$' | xargs -I{} ps u -p{} --no-headers
```
