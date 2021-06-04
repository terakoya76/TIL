## inotifywait

### Install
```bash
$ apt update && apt install -y inotify-tools
```

### Usage
inode に変更入る場合（recreate）、`-e modify` だと event を拾えない。
`-e attrib` を使うと拾える。

```bash
$ inotifywait -m -e attrib /etc/my-metadata/metadata
Setting up watches.
Watches established.

# 別 term で k edit cm my-metadata する

/etc/my-metadata/metadata ATTRIB
```

event 検知で任意の処理を実行する
```bash
while inotifywait -e attrib -q /etc/my-metadata/metadata; do
  echo $(cat /etc/my-metadata/metadata)
done

# 別 term で modify
/etc/my-metadata/metadata ATTRIB
hoge,fuga,piyo,poin

# 別 term で modify
/etc/my-metadata/metadata ATTRIB
hoge,fuga,piyo
```
