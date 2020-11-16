## Row-based replication: attribute promotion and demotion
Ref: https://dev.mysql.com/doc/refman/5.7/en/replication-features-differing-tables.html

### Type conversion modes (slave_type_conversions variable)
*  `slave_type_conversions` global server variable で replica で type-conversion 方式を管理できる

#### `ALL_LOSSY`
データ喪失を伴う conversion のみを許容する
* `INT` to `TINYINT` といった `NO_LOSSY` の conversion は許容されない。
* Attempting the latter conversion in this case would cause replication to stop with an error on the replica.

#### `ALL_NON_LOSSY`
データ喪失を伴わない conversion のみを許容する
* Setting this mode has no bearing on whether lossy conversions are permitted; this is controlled with the `ALL_LOSSY` mode.
* If only `ALL_NON_LOSSY` is set, but not `ALL_LOSSY`, then attempting a conversion that would result in the loss of data (such as `INT` to `TINYINT`, or `CHAR(25)` to `VARCHAR(20)`) causes the replica to stop with an error.

#### `ALL_LOSSY`, `ALL_NON_LOSSY`
When this mode is set, all supported type conversions are permitted, whether or not they are lossy conversions.

#### `ALL_SIGNED`
Treat promoted integer types as signed values (the default behavior).

#### `ALL_UNSIGNED`
Treat promoted integer types as unsigned values.

#### `ALL_SIGNED`, `ALL_UNSIGNED`
Treat promoted integer types as signed if possible, otherwise as unsigned.

#### `[empty]`
This mode is the default.

* When `slave_type_conversions` is not set, no attribute promotion or demotion is permitted; this means that all columns in the source and target tables must be of the same types.
