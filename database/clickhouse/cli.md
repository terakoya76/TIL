# CLI

## Install

```bash
sudo apt-get install -y apt-transport-https ca-certificates dirmngr
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8919F6BD2B48D754

echo "deb https://packages.clickhouse.com/deb stable main" | sudo tee \
    /etc/apt/sources.list.d/clickhouse.list
sudo apt-get update

sudo apt-get install -y clickhouse-server clickhouse-client
```

## SQL

### List DB/tables
```sql
SELECT * FROM system.databases;
SELECT database, name FROM system.tables;
```

### Delete
> This feature is experimental and requires you to set allow_experimental_lightweight_delete to true:
* cf. https://clickhouse.com/docs/en/sql-reference/statements/delete

LightWeight Delelte
* cf. https://clickhouse.com/docs/en/guides/developer/lightweght-delete/

```sql
SET allow_experimental_lightweight_delete = true;
DELETE FROM db.table WHERE 1;
```

or DDL
```sql
GRANT ALTER DELETE ON db.table to username;
ALTER TABLE db.table DELETE WHERE 1
```

for Distributed
```sql
SET mutations_sync = 2;
ALTER TABLE db.table ON CLUSTER 'cluster' DELETE WHERE 1
```

### Result Format
* cf. [supported formats](https://clickhouse.com/docs/en/interfaces/formats/)

```sql
SELECT database, name FROM system.tables LIMIT 1 FORMAT Vertical;

Row 1:
──────
database: INFORMATION_SCHEMA
name:     COLUMNS
```

