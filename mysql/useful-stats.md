## Useful stats table provided by MySQL

for analyze workload
* mysql.slow_log
* mysql.general_log
* performance_schema.events_statements_summary_by_digest
* sys.schema_index_statistics
* sys.schema_table_statistics
* sys.statement_analysis
* sys.statements_with_errors_or_warnings
* sys.statements_with_full_table_scans
* sys.statements_with_runtimes_in_95th_percentile

for data size
* mysql.innodb_table_stats
* mysql.innodb_index_stats
* information_schema.tables
* sys.redundant_indexes
* sys.schema_unused_indexes

for process monitoring
* information_schema.INNODB_TRX
* performance_schema.threads
* performance_schema.events_statements_history
* performance_schema.events_stages_history

for I/O stats
* performance_schema.table_io_waits_summary_by_table
* performance_schema.file_summary_by_instance
* sys.innodb_lock_waits
* sys.schema_table_lock_waits
* sys.schema_table_statistics_io
