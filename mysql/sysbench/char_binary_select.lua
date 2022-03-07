#!/usr/bin/env sysbench

require("oltp_common")
local ulid_mod = require("ulid")
local socket = require ("socket")
ulid_mod.set_time_func(socket.gettime)

-- for build query from result set
ulids = {}

sysbench.cmdline.options = {
    tables = {"Number of tables", 1},
    table_size = {"Number of rows per table", 100000},
    point_selects = {"Num of select within trx", 1000},
    id_type = {"Id type", "Char"},
    mysql_storage_engine = {"Storage engine, if MySQL is used", "innodb"},
    create_secondary = {"Create a secondary key", true},
    create_table_options = {"Extra CREATE TABLE options", "DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci"},
    skip_trx = {"Whether wrapping selects by transaction or not", false},
    network_mode = {"Check Network Latency", false},
}

-- called from prepare cmd
function create_table(drv, con, table_num)
    print(string.format("Creating table 'sbtest%d'...", table_num))

    local id_def
    if sysbench.opt.id_type == "Int" then
        id_def = "Int AUTO_INCREMENT"
    else
        id_def = string.format("%s(26)", sysbench.opt.id_type)
    end

    local engine_def = "/*! ENGINE = " .. sysbench.opt.mysql_storage_engine .. " */"
    local query = string.format([[
CREATE TABLE sbtest%d(
  id %s PRIMARY KEY NOT NULL,
  k INTEGER DEFAULT '0' NOT NULL,
  c CHAR(120) DEFAULT '' NOT NULL,
  pad CHAR(60) DEFAULT '' NOT NULL
) %s %s]],
        table_num,
        id_def,
        engine_def,
        sysbench.opt.create_table_options)

    con:query(query)

    if (sysbench.opt.table_size > 0) then
        print(string.format("Inserting %d records into 'sbtest%d'",
                            sysbench.opt.table_size, table_num))
    end

    if sysbench.opt.id_type == "Int" then
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
        if sysbench.opt.id_type == "Int" then
            query = string.format("(%d, '%s', '%s')",
                                  sysbench.rand.default(1, sysbench.opt.table_size),
                                  c_val,
                                  pad_val)
        else
            query = string.format("('%s', %d, '%s', '%s')",
                                  ulid_mod.ulid(),
                                  sysbench.rand.default(1, sysbench.opt.table_size),
                                  c_val,
                                  pad_val)
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

-- called from thread_init
function prepare_statements()
    load_ulids()
    prepare_point_selects()

    if not sysbench.opt.skip_trx then
        prepare_begin()
        prepare_commit()
    end
end

function load_ulids()
    local rs = con:query(string.format("SELECT id FROM sbtest%d", 1))
    local row = ""

    while row ~= nil do
        row = rs:fetch_row()
        if row ~= nil then
            ulids[#ulids+1] = row[1]
        end
    end
end

-- per transaction
function event()
    if not sysbench.opt.skip_trx then
        begin()
    end

    execute_selects()

    if not sysbench.opt.skip_trx then
        commit()
    end
end

function execute_selects()
    local tnum = sysbench.rand.uniform(1, sysbench.opt.tables)

    for i = 1, sysbench.opt.point_selects do
        local str = ""
        local in_items = 1000

        for j = 1, in_items do
            if sysbench.opt.id_type == "Int" then
                local row_idx = sysbench.rand.default(1, sysbench.opt.table_size)
                local id = ulids[row_idx]

                if j == in_items then
                    str = str .. string.format("%d", id)
                else
                    str = str .. string.format("%d,", id)
                end
            else
                local row_idx = sysbench.rand.default(1, sysbench.opt.table_size)
                local id = ulids[row_idx]

                if j == in_items then
                    str = str .. string.format("'%s'", id)
                else
                    str = str .. string.format("'%s',", id)
                end
            end
        end

        if sysbench.opt.network_mode then
            con:query("SELECT 1")
        else
            con:query(string.format("SELECT * FROM sbtest%d WHERE id IN(%s)", tnum, str))
        end
    end
end

function sysbench.hooks.report_cumulative(stat)
    print(string.format("%s,%s,%s,%s," ..
                        "%s,%s," ..
                        "%s,%s," ..
                        "%s,%s," ..
                        "%s,%s," ..
                        "%s,%s,%s,%2dth_%s,%s,",
                    "reads",
                    "writes",
                    "other",
                    "queries",
                    "events",
                    "events/sec",
                    "queries",
                    "queries/sec",
                    "errors",
                    "errors/sec",
                    "reconnects",
                    "reconnects/sec",
                    "latency_min",
                    "latency_avg",
                    "latency_max",
                    sysbench.opt.percentile, "latency_pct",
                    "latency_sum"
    ))

    local queries = stat.reads + stat.writes + stat.other
    local seconds = stat.time_total
    print(string.format("%u,%u,%u,%u," ..
                        "%u,%.2f," ..
                        "%u,%.2f," ..
                        "%u,%.2f," ..
                        "%u,%.2f," ..
                        "%.2f,%.2f,%.2f,%.2f,%.2f",
                    -- queries performed
                    stat.reads,
                    stat.writes,
                    stat.other,
                    queries,
                    -- transactions
                    stat.events,
                    stat.events / seconds,
                    -- queries
                    queries,
                    queries / seconds,
                    -- ignored errors
                    stat.errors,
                    stat.errors / seconds,
                    -- reconnects
                    stat.reconnects,
                    stat.reconnects / seconds,
                    -- latency(ms)
                    stat.latency_min,
                    stat.latency_avg,
                    stat.latency_max,
                    stat.latency_pct,
                    stat.latency_sum
    ))
end

function sysbench.hooks.sql_error_ignorable(err)
    if err.sql_errno == 1047 then -- ER_UNKNOWN_COM_ERROR
        print("Node is out of sync, waiting to reconnect...")
        con:reconnect()
        return true
    end
end
