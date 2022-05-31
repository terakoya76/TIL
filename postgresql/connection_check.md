# Connection Check

client
```sql
SELECT * FROM pg_stat_activity;
```

server
```sql
SELECT 1 lno, 'current_database' descript, current_database() as info
UNION SELECT 2 lno, 'version' descript, substring(version() FROM 'PostgreSQL [0-9|.]*') as info
UNION SELECT 3 lno, 'inet_server_addr' descript, cast(inet_server_addr() as character varying) as info
UNION SELECT 4 lno, 'inet_server_port' descript, cast(inet_server_port() as character varying) as info
UNION SELECT 5 lno, 'current_user' descript, current_user as  info
UNION SELECT 6 lno, 'current_schema'   descript, current_schema() as info
UNION SELECT 7 lno, 'inet_client_addr' descript, cast(inet_client_addr() as character varying) as info
ORDER BY lno
;
```

replication
```sql
SELECT * FROM pg_stat_replication;
```
