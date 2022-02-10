# High Availability Configuration
Ref: https://docs.fluentd.org/deployment/high-availability

## Role
* `log forwarders`
  * are typically installed on every node to receive local events.
  * Once an event is received, they forward it to the `log aggregators` through the network.
  * For log forwarders, fluent-bit is also good candidate for light-weight processing.
* `log aggregators`
  * are daemons that continuously receive events from the `log forwarders`.
  * They buffer the events and periodically upload the data into the cloud.

## Config
* When the active aggregator (192.168.0.1) dies, the logs will instead be sent to the backup aggregator (192.168.0.2).
* If both servers die, the logs are buffered on-disk at the corresponding forwarder nodes.

```xml
# TCP input
<source>
  @type forward
  port 24224
</source>

# HTTP input
<source>
  @type http
  port 8888
</source>

# Log Forwarding
<match mytag.**>
  @type forward

  # primary host
  <server>
    host 192.168.0.1
    port 24224
  </server>
  # use secondary host
  <server>
    host 192.168.0.2
    port 24224
    standby
  </server>

  # use longer flush_interval to reduce CPU usage.
  # note that this is a trade-off against latency.
  <buffer>
    flush_interval 60s
  </buffer>
</match>
```

## Failure Case Scenarios
### Forwarder Failure
When a `log forwarder` receives events from applications, the events are first written into a disk buffer (specified by <buffer>'s path).
* After every flush_interval, the buffered data is forwarded to aggregators.

This process is inherently robust against data loss.
* If a log forwarder's fluentd process dies then on its restart the buffered data is properly transferred to its aggregator.
* If the network between forwarders and aggregators breaks, the data transfer is automatically retried.

However, possible message loss scenarios do exist:
* The process dies immediately after receiving the events, but before writing them into the buffer.
* The forwarder's disk is broken, and the file buffer is lost.

### Aggregator Failure
When `log aggregators` receive events from log forwarders, the events are first written into a disk buffer (specified by <buffer>'s path).
* After every flush_interval, the buffered data is uploaded to the cloud.

This process is inherently robust against data loss.
* If a log aggregator's fluentd process dies then on its restart the data from the log forwarder is properly retransferred.
* If the network between aggregators and the cloud breaks, the data transfer is automatically retried.

However, possible message loss scenarios do exist:
* The process dies immediately after receiving the events, but before writing them into the buffer.
* The aggregator's disk is broken, and the file buffer is lost.

### Edge Failure Case
Ref: https://abicky.net/2017/10/23/110103/

#### app -> log forwarder 間での消失
FluentLogger の BufferLimit 溢れ
* `log forwarder` が一時的にダウンした場合、fluent logger は一定量まで送信できなかったデータをメモリに蓄え、次に送信する際にまとめて送信します。
  * default 8MB
  * https://github.com/fluent/fluent-logger-ruby/blob/v0.7.1/lib/fluent/logger/fluent_logger.rb#L51
* よって、メモリに蓄えられる上限に収まっているうちに log forwarder が復旧すれば消失しませんが、上限を超えると fluent logger はためていたログを全て破棄するので、ダウンしていた間のデータは全て消失します。

不適切な停止順序
* また、app と log forwarder が同じサーバに存在している場合、サーバを停止する際には app を停止した後に log forwarder を停止しなければ log forwarder 停止後に送信しようとしたデータは消失します。

#### log forwarder 内での消失
input thread が buffer に書き込むまでの間にエラーが発生した場合
* 例えば overflow_action が throw_exception (default) で BufferOverflowError が起きるとこのケースに該当します。
  * cf. https://docs.fluentd.org/troubleshooting-guide#my-logs-are-filled-with-bufferoverflow-error
    * file buffer type
    * flush_interval is low enough
    * flush_thread_count is high enough
      * if you have excessive messages per second and Fluentd is failing to keep adjusting these two settings will increase Fluentd's resource utilization
    * total_limit_size is high enough
    * chunk_limit_size is high enough

flush_at_shutdown がない
* サーバの停止と共にストレージも削除するような設定になっていると、file buffer といえども flush_at_shutdown を true にしておかなければ、サーバの停止時に flush されていないデータは消失します。

#### log forwarder -> log aggregator 間での消失
retry_timeout, retry_max_times の超過
* log aggregator が一時的にダウンした場合、log forwarder は設定に応じてデータの送信をリトライします。
* retry_timeout か retry_max_times に到達するまでの間に log aggregator が復旧しなければログは消失します。
* もし secondary に file output plugin を指定しておけば、復旧時に手動で log aggregator へ送ることもできます。

#### log aggregator 内での消失
「log forwarder 内での消失」と同様

require_ack_response が true でない
* require_ack_response が true だと、`log aggregator` は buffer に書き込んだ後に ack response を返します。
* `log forwarder` は ack response が一定時間内に返ってこなければリトライするので、`log aggregator` の input thread でエラーが起きた場合や deadlock で処理できない状態になっている場合でもログは消失しません。
* 一方で、単に `log aggregator` 側の処理で時間がかかっている場合は二重にログを送信してしまうことになります。

#### log aggregator -> log destination 間での消失
「log forwarder -> log aggregator 間での消失」と同様
