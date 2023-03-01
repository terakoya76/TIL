# Online DDL overview
Ref: https://dev.mysql.com/doc/refman/5.6/ja/innodb-create-index-overview.html

## OnlineDDL が使えないケース
* ADD FULLTEXT INDEX
* カラムのデータ型を変更する
* 主キーを削除する
* 文字セットを変換する
* 文字セットを指定する

## 並列DMLが許容されるがコストの大きい操作
* カラムの追加、削除、または並べ替え。
* 主キーの追加または削除。
* テーブルの ROW_FORMAT または KEY_BLOCK_SIZE プロパティーの変更。
* カラムの Null にできるステータスの変更。
* OPTIMIZE TABLE
* FORCE オプションを使用したテーブルの再構築
* 「null」 ALTER TABLE ... ENGINE=INNODB ステートメントを使用したテーブルの再構築

## Online DDL on rails
テスト環境で OnlineDDL が許容される操作かを検証
```ruby
class AddColumnToDdlTest < ActiveRecord::Migration
  def up
    execute <<~SQL
      ALTER TABLE partners
      ADD COLUMN ddl_test VARCHAR(255),
      ALGORITHM=INPLACE,
      LOCK=NONE;
    SQL
  end

  def down
    remove_column :partners, :ddl_test
  end
end
```

問題なければ入れる
metadata lock を監視する仕組みを用い、lock にかかっていたら何かしらの手段で abort する
```ruby
class AddColumnToDdlTest < ActiveRecord::Migration
  def up
    add_column :partners, :ddl_test, :string
  end

  def down
    remove_column :partners, :ddl_test
  end
end
```

## 完了進捗
```sql
-- performance_schema 有効化
set global performance_schema = ON;
UPDATE performance_schema.setup_instruments
  SET ENABLED = ‘YES’, TIMED = ‘YES’
  WHERE NAME LIKE ‘stage/innodb/alter%’;
UPDATE performance_schema.setup_consumers
  SET ENABLED = ‘YES’
  WHERE NAME LIKE ‘%stages%’;

-- 確認
SELECT EVENT_NAME, WORK_COMPLETED, WORK_ESTIMATED
FROM performance_schema.events_stages_current;
+------------------------------+---------------------------+-----------------------+
| EVENT_NAME                   | WORK_COMPLETED            |  WORK_ESTIMATED       |
| stage/sql/copy to tmp table  |    1562071                |  2838662              |
+------------------------------+---------------------------+-----------------------+
```
