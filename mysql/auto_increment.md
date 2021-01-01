## Auto Increment
Ref: https://dev.mysql.com/doc/refman/5.6/ja/innodb-auto-increment-handling.html

### 定義
#### INSERT のような statement
* INSERT、INSERT ... SELECT、REPLACE、REPLACE ... SELECT、LOAD DATA など、 table 内に新しい行を生成するすべての statement です。

#### 単純挿入
* statement の初期処理時に挿入行数を事前に決定できる statement です。
* これには、ネストした subquery を持たない単一行および複数行の INSERT および REPLACE statement が含まれますが、INSERT ... ON DUPLICATE KEY UPDATE は含まれません。

#### 一括挿入
* 挿入行数および必要な自動 increment 値の数が事前にわからない statement です。
* これには、INSERT ... SELECT、REPLACE ... SELECT、および LOAD DATA statement が含まれますが、単純な INSERT は含まれません。
* InnoDB は各行を処理する際に、AUTO_INCREMENT column の新しい値を一度に1つずつ割り当てます。

#### 混在モード挿入
* 新しい行の一部 (全部ではない) の自動 increment 値を指定する 「単純挿入」 statement です。
* 次の例を示します。c1 は table t1 の AUTO_INCREMENT column です。
```sql
INSERT INTO t1 (c1,c2) VALUES (1,'a'), (NULL,'b'), (5,'c'), (NULL,'d');
```

### Rollback
すべての lock mode (0、1、および 2) では、自動 increment 値を生成した trx が rollback されると、これらの自動 increment 値が「失われます」。
* 「INSERT のような」statement が完了したかどうか、およびそれを含む trx が rollback されたかどうかに関係なく、自動 increment column の値は一度生成されたら、rollback できません。
* このような失われた値は再使用されません。したがって、テーブルの AUTO_INCREMENT column に格納されている値にはギャップが存在する可能性があります。

### autoinc lock mode
#### 従来
すべての 「INSERT のような」statement では、特殊な table level AUTO-INC lock が取得され、statement の終了まで保持されます。
* これにより、特定の statement によって割り当てられた自動 increment 値が連続的になります。
* InnoDB  table に AUTO_INCREMENT column を指定すると、InnoDB データディクショナリ内の table に、column に新しい値を割り当てる際に使用される自動インクリメントカウンタと呼ばれる特別なカウンタが含まれます。
  * この counter は、disk 上には格納されず、main memory 内にのみ格納されます。
* InnoDB では、server が実行されていれば、in-memory の自動 increment counter が使用されます。
* server が停止して再起動されると、table への最初の INSERT 時に、InnoDB によって table ごとにカウンタが再初期化されます。
```sql
SELECT MAX(ai_col) FROM t FOR UPDATE;
```

#### 連続
このモードでは、「一括挿入」 は特殊な AUTO-INC table level lock を使用し、その lock を statement の終了まで保持します。
* これは、INSERT ... SELECT、REPLACE ... SELECT、LOAD DATA のすべての statement に当てはまります。
* 一度に実行できる statement は、AUTO-INC lock を保持している1つの statement だけです。
* 行数が事前にわからない INSERT statement が存在する場合には、任意の 「INSERT のような」 statement によって割り当てられたすべての自動 increment 値が必ず連続した値になるため、その処理は、SBR でも安全に利用できる

#### インターリーブ
* このロックモードでは、テーブルレベル AUTO-INC lock を使用する 「INSERT のような」statement は1つも存在しないため、複数の statement を同時に実行できます。
  * 自動インクリメント値は一意であり、並列実行されているすべての 「INSERT のような」statement にわたって単調に増加することが保証されます
  * ただし、複数の statement が同時に番号を生成している (つまり番号の割り当てが複数の statement 間で interleave されている) 可能性があるため、任意の statement によって挿入される行に対して生成された値が連続的でない可能性があります
* これはもっとも高速で、もっとも拡張性の高い lock mode です。
* ただし、SBR を使用する場合や、リカバリシナリオで binlog から SQL statement を再現する際には、安全ではありません。
