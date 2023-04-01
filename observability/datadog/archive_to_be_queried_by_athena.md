# datadog-archive した logs を athena から query 可能にする

Ref: Partition Projectionを利用する
* https://dev.classmethod.jp/articles/20200627-amazon-athena-partition-projection/
* https://dev.classmethod.jp/articles/20200727-amazon-athena-partition-projection-for-hive-partition/


Athena DDLでテーブルを作成
```sql
CREATE EXTERNAL TABLE `datadog_archive`(
  `_id` string,
  `date` string,
  `service` string,
  `host` string,
  `status` string,
  `source` string,
  `attributes` string,
  `tags` array<string>
)
PARTITIONED BY (
  `dt` string,
  `hour` int)
ROW FORMAT SERDE
  'org.openx.data.jsonserde.JsonSerDe'
STORED AS INPUTFORMAT
  'org.apache.hadoop.mapred.TextInputFormat'
OUTPUTFORMAT
  'org.apache.hadoop.hive.ql.io.IgnoreKeyTextOutputFormat'
LOCATION
  's3://my-log/datadog'
TBLPROPERTIES (
  'projection.dt.format'='yyyyMMdd',
  'projection.dt.interval'='1',
  'projection.dt.interval.unit'='DAYS',
  'projection.dt.range'='NOW-2YEARS,NOW',
  'projection.dt.type'='date',
  'projection.hour.digits'='2',
  'projection.hour.interval'='1',
  'projection.hour.range'='0,23',
  'projection.hour.type'='integer',
  'projection.enabled'='true',
  'storage.location.template'='s3://my-log/datadog/dt=${dt}/hour=${hour}')
```
