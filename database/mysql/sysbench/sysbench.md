# sysbench

## Typical Test

Typical Test Scenario

| Scenario        | Desc            |
|-----------------|-----------------|
| oltp_read_write | read/write OLTP |
| oltp_read_only  | read OLTP       |
| oltp_write_only | write OLTP      |


### Mac
```bash
$ brew install sysbench

$ conn="--db-driver=mysql --mysql-host=127.0.0.1 --mysql-user=root --mysql-password=root --mysql-db=sbtest"

$ sysbench $conn \
      oltp_read_write \
      prepare

$ sysbench $conn oltp_read_write \
    --threads=16 --time=120 --table-size=1000000 run

$ sysbench $conn \
      oltp_read_write \
      cleanup
```

## Builtin Option
### General Option
```c
SB_OPT("threads",
     "number of threads to use",
     "1", INT),
SB_OPT("events",
     "limit for total number of events",
     "0", INT),
SB_OPT("time",
     "limit for total execution time in seconds",
     "10", INT),
SB_OPT("warmup-time",
     "execute events for this many seconds with statistics disabled before the actual benchmark run with statistics enabled",
     "0", INT),
SB_OPT("forced-shutdown",
     "number of seconds to wait after the --time limit before forcing shutdown, or 'off' to disable",
     "off", STRING),
SB_OPT("thread-stack-size",
     "size of stack per thread",
     "64K", SIZE),
SB_OPT("thread-init-timeout",
     "wait time in seconds for worker threads to initialize",
     "30", INT),
SB_OPT("rate",
     "average transactions rate. 0 for unlimited rate",
     "0", INT),
SB_OPT("report-interval",
     "periodically report intermediate statistics with a specified interval in seconds. 0 disables intermediate reports",
     "0", INT),
SB_OPT("report-checkpoints",
     "dump full statistics and reset all counters at specified points in time. The argument is a list of comma-separated values representing the amount of time in seconds elapsed from start of test when report checkpoint(s) must be performed. Report checkpoints are off by default.",
     "", LIST),
SB_OPT("debug",
     "print more debugging info",
     "off", BOOL),
SB_OPT("validate",
     "perform validation checks where possible",
     "off", BOOL),
SB_OPT("help",
     "print help and exit",
     "off", BOOL),
SB_OPT("version",
     "print version and exit",
     "off", BOOL),
SB_OPT("config-file",
     "File containing command line options",
     NULL, FILE),
SB_OPT("luajit-cmd",
     "perform LuaJIT control command. This option is equivalent to 'luajit -j'. See LuaJIT documentation for more information",
     NULL, STRING),
```
https://github.com/akopytov/sysbench/blob/df89d34c410a2277e19f77e47e535d0890b2029b/src/sysbench.c#L94-L121


### OLTP Option
```lua
table_size =
  {"Number of rows per table",
   10000},
range_size =
  {"Range size for range SELECT queries",
   100},
tables =
  {"Number of tables",
   1},
point_selects =
  {"Number of point SELECT queries per transaction",
   10},
simple_ranges =
  {"Number of simple range SELECT queries per transaction",
   1},
sum_ranges =
  {"Number of SELECT SUM() queries per transaction",
   1},
order_ranges =
  {"Number of SELECT ORDER BY queries per transaction",
   1},
distinct_ranges =
  {"Number of SELECT DISTINCT queries per transaction",
   1},
index_updates =
  {"Number of UPDATE index queries per transaction",
   1},
non_index_updates =
  {"Number of UPDATE non-index queries per transaction",
   1},
delete_inserts =
  {"Number of DELETE/INSERT combinations per transaction",
   1},
range_selects =
  {"Enable/disable all range SELECT queries",
   true},
auto_inc =
  {"Use AUTO_INCREMENT column as Primary Key (for MySQL), or its alternatives in other DBMS. When disabled, use client-generated IDs",
   true},
create_table_options =
  {"Extra CREATE TABLE options", ""},
skip_trx =
  {"Don't start explicit transactions and execute all queries in the AUTOCOMMIT mode",
   false},
secondary =
  {"Use a secondary index in place of the PRIMARY KEY",
   false},
create_secondary =
  {"Create a secondary index in addition to the PRIMARY KEY",
   true},
reconnect =
  {"Reconnect after every N events. The default (0) is to not reconnect",
   0},
mysql_storage_engine =
  {"Storage engine, if MySQL is used",
   "innodb"},
pgsql_variant =
  {"Use this PostgreSQL variant when running with the PostgreSQL driver. The only currently supported variant is 'redshift'. When enabled, create_secondary is automatically disabled, and delete_inserts is set to 0"}
```
https://github.com/akopytov/sysbench/blob/ead2689ac6f61c5e7ba7c6e19198b86bd3a51d3c/src/lua/oltp_common.lua#L34-L81
