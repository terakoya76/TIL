## Type Conflict
すでに作られてしまった mappings は更新できないので、希望する mappings を持つ新しい index を作って、reindex を掛けるしかない

```bash
ENDPOINT="elastic/search/endpoint"

for idx in `cat conflict-index-list.txt | grep <index-name-prefix>`
do
    curl -XPUT -H "Content-Type: application/json" "$ENDPOINT/tmp-$idx" -d "{\"mappings\":{\"cebu\":{\"properties\":{\"company_id\":{\"type\": \"long\"}}}}}"
    echo 'add tmp index'
    sleep 3

    curl -XPOST -H "Content-Type: application/json" "$ENDPOINT/_reindex" -d "{\"source\": {\"index\": \"$idx\"},\"dest\": {\"index\": \"tmp-$idx\"}}"
    echo 'reindex from old to tmp'
    sleep 3

    #
    # You may add another backup of new other than tmp
    #

    curl -XDELETE "$ENDPOINT/$idx"
    echo 'delete old'
    sleep 3

    curl -XPUT -H "Content-Type: application/json" "$ENDPOINT/$idx" -d "{\"mappings\":{\"cebu\":{\"properties\":{\"company_id\":{\"type\": \"long\"}}}}}"
    echo 'add new index'
    sleep 3

    curl -XPOST -H "Content-Type: application/json" "$ENDPOINT/_reindex" -d "{\"source\": {\"index\": \"tmp-$idx\"},\"dest\": {\"index\": \"$idx\"}}"
    echo 'reindex from tmp to new'
    sleep 3
done

for idx in `cat conflict-index-list.txt | grep <index-name-prefix>`
do
    curl -XDELETE "$ENDPOINT/tmp-$idx"
    echo 'delete tmp'
    sleep 3
done
```
