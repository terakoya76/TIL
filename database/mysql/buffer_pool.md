# Buffer Pool

Bufferpoolの中に存在しているUser用のテーブルのリスト
```sql
SELECT DISTINCT(TABLE_NAME)
FROM INFORMATION_SCHEMA.INNODB_BUFFER_PAGE
WHERE INSTR(TABLE_NAME, '.') != 0
  AND (STRCMP(LEFT(TABLE_NAME,7) , "\`mysql\`") != 0);
```

Bufferpoolの中に存在しているUser用のテーブルのだいたいのページ数
```sql
SELECT COUNT(*)
FROM INFORMATION_SCHEMA.INNODB_BUFFER_PAGE
WHERE INSTR(TABLE_NAME, '.') != 0
  AND (STRCMP(LEFT(TABLE_NAME,7) , "\`mysql\`") != 0);
```

Bufferpoolの中に存在しているUser用のテーブルがどれくらいの割合か
```sql
SELECT
  (SELECT COUNT(*)
   FROM INFORMATION_SCHEMA.INNODB_BUFFER_PAGE
   WHERE INSTR(TABLE_NAME, '.') != 0
     AND (STRCMP(LEFT(TABLE_NAME,7) , "\`mysql\`") != 0)
  ) AS user_pages,
  (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.INNODB_BUFFER_PAGE
  ) AS total_pages,
  (
    SELECT ROUND((user_pages/total_pages) * 100)
  ) AS user_page_percentage;
```
