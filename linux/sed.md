# sed

ファイル名一括置換
```bash
$ find <filename> | xargs sed -i "s/<before>/<after>/g"
```

content 一括置換
```bash
$ git grep <string> | cut -d: -f1 | xargs sed -i "s/<before>/<after>/g"
```
