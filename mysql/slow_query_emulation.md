# Slow Query Emulation

Ref: https://qiita.com/rubytomato@github/items/acc3bf064b3ceff406d4

```sql
mysql> CREATE OR REPLACE VIEW temp_v (id, sleep, create_at) AS SELECT UUID() AS id, SLEEP(30) AS sleep, NOW() AS create_at;
mysql> select * from temp_v;
```
