# Storage Size

## Total Size
```sql
SELECT
  relname AS tablename,
  n_live_tup + n_dead_tup + n_mod_since_analyze AS total_tuple_count,
  pg_size_pretty(pg_total_relation_size(quote_ident(relname))) AS simple_size,
  pg_relation_size(quote_ident(relname)) AS size_in_bytes
FROM pg_stat_user_tables;
```

## Per User Space Size
```sql
SELECT
  relname AS tablename,
  n_live_tup + n_dead_tup + n_mod_since_analyze AS total_tuple_count,
  pg_size_pretty(pg_total_relation_size(quote_ident(relname))) AS simple_size,
  pg_relation_size(quote_ident(relname)) AS size_in_bytes
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY tablename;
```

## Total User Space Size
```sql
SELECT
  SUM(n_live_tup + n_dead_tup + n_mod_since_analyze) AS total_tuple_count,
  pg_size_pretty(SUM(pg_total_relation_size(quote_ident(relname)))) AS simple_size,
  SUM(pg_relation_size(quote_ident(relname))) AS size_in_bytes
FROM pg_stat_user_tables
WHERE schemaname = 'public';
```
