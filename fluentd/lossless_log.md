## Lossless Log

Ref:
* http://blog.livedoor.jp/sonots/archives/44690980.html?ref=popular_article&id=5419188-3748581

fluentd documentation
* https://docs.fluentd.org/output/forward
* https://docs.fluentd.org/plugin-helper-overview/api-plugin-helper-compat_parameters
* https://docs.fluentd.org/configuration/buffer-section


前提
* ulimit の調整

### 0.12 compat
```xml
<source>
  @type tail
  tag raw.eventlog
</source>

<match raw.**>
  @type forward
  @log_level info

  <buffer>
    @type file
    path /var/log/fluentd-sender/buffer/buffer

    # default: none
    # The maximum number of times to retry to flush the failed chunks
    retry_max_times 10

    # default: 8MB(memory)/256MB(file)
    # The max size of each chunks: events will be written into chunks until the size of chunks become this size or flush interval reaches
    chunk_limit_size 4m

    # default: 60
    flush_interval 30s

    # default: nil
    # The queue length limitation of this buffer plugin instance
    # NOTE: DO NOT discard new incoming data anyway
    queue_limit_length 9999999999999

    # default: 1
    # The sleep interval (seconds) for threads to wait for the next flush try
    flush_thread_interval 1

    # default: 1
    # The sleep interval (seconds) for threads between flushes when the output plugin flushes the waiting chunks to the next ones
    flush_thread_burst_interval 1

    # default: 1
    # NOTE: 64Mbps (2 * 4m / 1 sec) at maximum, adjust it along w/ the workload
    flush_thread_count 2

    # default: 1.0
    # Wait in seconds before the next retry to flush or constant factor of exponential backoff
    retry_wait 30s

    # default: inifinity
    # The maximum interval (seconds) for exponential backoff between retries while failing
    retry_max_interval 1h

    # default: false
    # If true, plugin will ignore retry_timeout and retry_max_times options and retry flushing forever
    # NOTE: DO NOT discard buffer anyway
    retry_forever true
  </buffer>

  # Changes the protocol to at-least-once
  # NOTE: need removal logic of the duplications like embedding uuid
  require_ack_response true

  # default: 60s
  send_timeout 60s

  # default: 190s
  ack_response_timeout 61s

  # default: transport
  heartbeat_type tcp

  # default: 10s
  # The wait time before accepting a server fault recovery.
  recover_wait 10s

  # default: 16
  # The threshold parameter used to detect server faults.
  phi_threshold 16

  # default: equals to send_timeout
  # The hard timeout used to detect server failure.
  hard_timeout 60s

  <server>
    host foobar
    port 24224
  </server>
</match>
```

### v1
```xml
<source>
  @type tail
  tag raw.eventlog
</source>

<match raw.**>
  @type forward
  @log_level info

  <buffer>
    @type file
    path /var/log/fluentd-sender/buffer/buffer

    # default: none
    # The maximum number of times to retry to flush the failed chunks
    retry_max_times 10

    # default: 8MB(memory)/256MB(file)
    # The max size of each chunks: events will be written into chunks until the size of chunks become this size or flush interval reaches
    chunk_limit_size 4m

    # default: 60
    flush_interval 30s

    # default: 512MB (memory)/64GB (file)
    # total_limit_size 64g

    # default: 0.95
    # The percentage of chunk size threshold for flushing output plugin will flush the chunk when actual size reaches
    # chunk_limit_size * chunk_full_threshold (== 8MB * 0.95 in default)
    chunk_full_threshold 0.9

    # default: 1
    # The sleep interval (seconds) for threads to wait for the next flush try
    flush_thread_interval 1

    # default: 1
    # The sleep interval (seconds) for threads between flushes when the output plugin flushes the waiting chunks to the next ones
    flush_thread_burst_interval 1

    # default: 1
    # NOTE: 64Mbps (2 * 4m / 1 sec) at maximum, adjust it along w/ the workload
    flush_thread_count 2

    # default: 1.0
    # Wait in seconds before the next retry to flush or constant factor of exponential backoff
    retry_wait 30s

    # default: inifinity
    # The maximum interval (seconds) for exponential backoff between retries while failing
    retry_max_interval 1h

    # default: false
    # If true, plugin will ignore retry_timeout and retry_max_times options and retry flushing forever
    # NOTE: DO NOT discard buffer anyway
    retry_forever true

    # default: 60
    # The timeout until output plugin decides if the async write operation has failed
    delayed_commit_timeout 60
  </buffer>

  # Changes the protocol to at-least-once
  # NOTE: need removal logic of the duplications like embedding uuid
  require_ack_response true

  # default: 60s
  send_timeout 60s

  # default: 190s
  ack_response_timeout 61s

  # default: transport
  heartbeat_type tcp

  # default: 10s
  # The wait time before accepting a server fault recovery.
  recover_wait 10s

  # default: 16
  # The threshold parameter used to detect server faults.
  phi_threshold 16

  # default: equals to send_timeout
  # The hard timeout used to detect server failure.
  hard_timeout 60s

  <server>
    host foobar
    port 24224
  </server>
</match>
```
