# Custom Scenario
* https://kaamos.me/talks/fosdem17/#/sec-title-slide
* https://medium.com/@amol.deshmukh_97340/running-custom-workloads-with-sysbench-c6d5338a503b

## LuaJIT
```bash
# luarocks と LuaJIT が利用する Lua の version を揃える
$ eval $(luarocks --lua-dir=/usr/local/opt/lua@5.1 path --bin)
$ export LUA_PATH='/usr/local/share/lua/5.1/?.lua;/usr/share/lua/5.1;/usr/local/share/sysbench/?.lua;/Users/terasawa-hajime/.luarocks/share/lua/5.1/?.lua'

$ sysbench $conn ./mysql/sysbench/char_binary_select.lua     --threads=16 --events=10 --time=120 --table-size=1000000 prepare
$ sysbench $conn ./mysql/sysbench/char_binary_select.lua     --threads=16 --events=10 --time=120 --table-size=1000000 run
$ sysbench $conn ./mysql/sysbench/char_binary_select.lua     --threads=16 --events=10 --time=120 --table-size=1000000 cleanup
```


## 主要な function
```c
#define EVENT_FUNC "event"
#define PREPARE_FUNC "prepare"
#define CLEANUP_FUNC "cleanup"
#define HELP_FUNC "help"
#define THREAD_INIT_FUNC "thread_init"
#define THREAD_DONE_FUNC "thread_done"
#define THREAD_RUN_FUNC "thread_run"
#define INIT_FUNC "init"
#define DONE_FUNC "done"
```
### prepare
```lua
function cmd_prepare()
   local drv = sysbench.sql.driver()
   local con = drv:connect()

   for i = sysbench.tid % sysbench.opt.threads + 1, sysbench.opt.tables,
   sysbench.opt.threads do
     create_table(drv, con, i)
   end
end
```
https://github.com/akopytov/sysbench/blob/df89d34c410a2277e19f77e47e535d0890b2029b/src/lua/oltp_common.lua#L86-L94

```lua
function create_table(drv, con, table_num)
   local id_index_def, id_def
   local engine_def = ""
   local extra_table_options = ""
   local query

   if sysbench.opt.secondary then
     id_index_def = "KEY xid"
   else
     id_index_def = "PRIMARY KEY"
   end

   if drv:name() == "mysql"
   then
      if sysbench.opt.auto_inc then
         id_def = "INTEGER NOT NULL AUTO_INCREMENT"
      else
         id_def = "INTEGER NOT NULL"
      end
      engine_def = "/*! ENGINE = " .. sysbench.opt.mysql_storage_engine .. " */"
   elseif drv:name() == "pgsql"
   then
      if not sysbench.opt.auto_inc then
         id_def = "INTEGER NOT NULL"
      elseif pgsql_variant == 'redshift' then
        id_def = "INTEGER IDENTITY(1,1)"
      else
        id_def = "SERIAL"
      end
   else
      error("Unsupported database driver:" .. drv:name())
   end

   print(string.format("Creating table 'sbtest%d'...", table_num))

   query = string.format([[
CREATE TABLE sbtest%d(
  id %s,
  k INTEGER DEFAULT '0' NOT NULL,
  c CHAR(120) DEFAULT '' NOT NULL,
  pad CHAR(60) DEFAULT '' NOT NULL,
  %s (id)
) %s %s]],
      table_num, id_def, id_index_def, engine_def,
      sysbench.opt.create_table_options)

   con:query(query)

   if (sysbench.opt.table_size > 0) then
      print(string.format("Inserting %d records into 'sbtest%d'",
                          sysbench.opt.table_size, table_num))
   end

   if sysbench.opt.auto_inc then
      query = "INSERT INTO sbtest" .. table_num .. "(k, c, pad) VALUES"
   else
      query = "INSERT INTO sbtest" .. table_num .. "(id, k, c, pad) VALUES"
   end

   con:bulk_insert_init(query)

   local c_val
   local pad_val

   for i = 1, sysbench.opt.table_size do

      c_val = get_c_value()
      pad_val = get_pad_value()

      if (sysbench.opt.auto_inc) then
         query = string.format("(%d, '%s', '%s')",
                               sysbench.rand.default(1, sysbench.opt.table_size),
                               c_val, pad_val)
      else
         query = string.format("(%d, %d, '%s', '%s')",
                               i,
                               sysbench.rand.default(1, sysbench.opt.table_size),
                               c_val, pad_val)
      end

      con:bulk_insert_next(query)
   end

   con:bulk_insert_done()

   if sysbench.opt.create_secondary then
      print(string.format("Creating a secondary index on 'sbtest%d'...",
                          table_num))
      con:query(string.format("CREATE INDEX k_%d ON sbtest%d(k)",
                              table_num, table_num))
   end
end
```
https://github.com/akopytov/sysbench/blob/df89d34c410a2277e19f77e47e535d0890b2029b/src/lua/oltp_common.lua#L157-L248

```lua
function connection_methods.bulk_insert_init(self, query)
   return assert(ffi.C.db_bulk_insert_init(self, query, #query) == 0,
                 "db_bulk_insert_init() failed")
end
```
https://github.com/akopytov/sysbench/blob/df89d34c410a2277e19f77e47e535d0890b2029b/src/lua/internal/sysbench.sql.lua#L287-L290

## 設定可能な hook
### Report Hook
```c
#define REPORT_INTERMEDIATE_HOOK "report_intermediate"
#define REPORT_CUMULATIVE_HOOK "report_cumulative"
```
https://github.com/akopytov/sysbench/blob/df89d34c410a2277e19f77e47e535d0890b2029b/src/sb_lua.c#L52-L62


standard reportsはhuman-readable。出力情報の変更や、フォーマットをmachine-readableにしたいときなどは `report_intermediate`, `report_cumulative` を上書く

```c
function sysbench.hooks.report_intermediate(stat)
    local seconds = stat.time_interval
    print(string.format("%.0f,%u,%4.2f,%4.2f,%4.2f,%4.2f,%4.2f,%4.2f,%4.2f,%4.2f",
                        stat.time_total, stat.threads_running,
                        stat.events / seconds, (stat.reads + stat.writes + stat.other) / seconds,
                        stat.reads / seconds, stat.writes / seconds, stat.other / seconds,
                        stat.latency_pct * 1000, stat.errors / seconds, stat.reconnects / seconds))
end
```

渡されるstat
```c
typedef struct {
  uint32_t threads_running;     /* Number of active threads */

  double   time_interval;       /* Time elapsed since the last report */
  double   time_total;          /* Time elapsed since the benchmark start */

  double   latency_pct;         /* Latency percentile */

  double   latency_min;         /* Minimum latency (cumulative reports only) */
  double   latency_max;         /* Maximum latency (cumulative reports only) */
  double   latency_avg;         /* Average latency (cumulative reports only) */
  double   latency_sum;         /* Sum latency (cumulative reports only) */

  uint64_t events;              /* Number of executed events */
  uint64_t reads;               /* Number of read operations */
  uint64_t writes;              /* Number of write operations */
  uint64_t other;               /* Number of other operations */
  uint64_t errors;              /* Number of ignored errors */
  uint64_t reconnects;          /* Number of reconnects to server */

  uint64_t bytes_read;          /* Bytes read */
  uint64_t bytes_written;       /* Bytes written */

  uint64_t queue_length;        /* Event queue length (tx_rate-only) */
  uint64_t concurrency;         /* Number of in-flight events (tx_rate-only) */
} sb_stat_t;
```
https://github.com/akopytov/sysbench/blob/df89d34c410a2277e19f77e47e535d0890b2029b/src/sysbench.h#L88-L113

### Error Hook
```lua
sysbench.hooks = {
   -- sql_error_ignorable = <func>,
   -- report_intermediate = <func>,
   -- report_cumulative = <func>
}
```
https://github.com/akopytov/sysbench/blob/df89d34c410a2277e19f77e47e535d0890b2029b/src/lua/internal/sysbench.lua#L62-L66

