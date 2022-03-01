# TLS

## Whether using TLS or NOT

```sql
SELECT id, user, host, connection_type
FROM performance_schema.threads pst
INNER JOIN information_schema.processlist isp
  ON pst.processlist_id = isp.id;

+----+-----------------+------------------+-----------------+
| id | user            | host             | connection_type |
+----+-----------------+------------------+-----------------+
| 8  | admin           | 10.0.4.249:42590 | SSL/TLS         |
| 4  | event_scheduler | localhost        | NULL            |
| 10 | webapp1         | 159.28.1.1:42189 | SSL/TLS         |
+----+-----------------+------------------+-----------------+
3 rows in set (0.00 sec)
```
