# Bigquery

Unused Dataset
```sql
WITH
  referenced_dataset AS(
  SELECT
    referenced_table.project_id,
    referenced_table.dataset_id
  FROM
    `region-us.INFORMATION_SCHEMA.JOBS_BY_PROJECT`
  JOIN
    UNNEST(referenced_tables)referenced_table)
SELECT DISTINCT
  table_catalog,
  table_schema
FROM
  `region-us.INFORMATION_SCHEMA.TABLES`
LEFT JOIN
  referenced_dataset
ON
  table_catalog=project_id
  AND table_schema=dataset_id
WHERE
  project_id IS NULL
```

Unused Table
```sql
WITH
  referenced_dataset AS(
  SELECT
    referenced_table.project_id,
    referenced_table.dataset_id,
    referenced_table.table_id
  FROM
    `region-us.INFORMATION_SCHEMA.JOBS_BY_PROJECT`
  JOIN
    UNNEST(referenced_tables)referenced_table)
SELECT DISTINCT
  table_catalog,
  table_schema,
  table_name
FROM
  `region-us.INFORMATION_SCHEMA.TABLES`
LEFT JOIN
  referenced_dataset
ON
  table_catalog=project_id
  AND table_schema=dataset_id
  AND table_name=table_id
WHERE
  project_id IS NULL
```

Storage Usage
```sql
SELECT * FROM `region-us`.INFORMATION_SCHEMA.TABLE_STORAGE
```

Check Partition Usage
```sql
SELECT
  table_catalog,
  table_schema,
  table_name,
  ddl
FROM
  `region-us.INFORMATION_SCHEMA.TABLES`
WHERE
  table_schema = '<dataset name>'
```
