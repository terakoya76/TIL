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

### Log Forwarders Failure

When a `log forwarder` receives events from applications, the events are first written into a disk buffer (specified by <buffer>'s path）.
* After every flush_interval, the buffered data is forwarded to aggregators.

This process is inherently robust against data loss.
* If a log forwarder's Fluentd process dies then on its restart the buffered data is properly transferred to its aggregator.
* If the network between forwarders and aggregators breaks, the data transfer is automatically retried.

However, possible message loss scenarios do exist:
* The process dies immediately after receiving the events, but before writing them into the buffer.
* The forwarder's disk is broken, and the file buffer is lost.

### Log Aggregators Failure

`log aggregators` が `log forwarders` からイベントを受け取ると、イベントはまずディスクバッファ（<buffer>のパスで指定）に書き込まれます。
* `flush_interval` ごとに、バッファリングされたデータがクラウドにアップロードされます。

このプロセスは、データ損失に対して本質的に堅牢です。
* `log aggregators` のFluentdプロセスが死んだ場合、その再起動時に `log forwarders` からのデータがまさしく再転送されます。
* `log aggregators` とクラウド間のネットワークが壊れた場合、データ転送は自動的に再試行されます。

しかし、メッセージロスの可能性は存在します。
* イベントを受信した後、バッファに書き込む前にプロセスが即座に死ぬ場合。
* `log aggregators` のディスクが壊れ、ファイルバッファが失われる。

### Edge Failure Case

Ref: https://abicky.net/2017/10/23/110103/

#### app -> `log forwarders` 間での消失

FluentLoggerのBufferLimit溢れ
* `log forwarders` が一時的にダウンした場合、`fluent logger` は一定量まで送信できなかったデータをメモリに蓄え、次に送信する際にまとめて送信します。
  * default 8MB
  * https://github.com/fluent/fluent-logger-ruby/blob/v0.7.1/lib/fluent/logger/fluent_logger.rb#L51
* よって、メモリに蓄えられる上限に収まっているうちに `log forwarders` が復旧すれば消失しませんが、上限を超えると `fluent logger` はためていたログをすべて破棄するので、ダウンしていた間のデータはすべて消失します

不適切な停止順序
* また、appと `log forwarders` が同じサーバに存在している場合、サーバを停止する際にはappを停止した後に `log forwarders` を停止しなければ、`log forwarders` 停止後に送信しようとしたデータは消失します。

#### log forwarder 内での消失

input threadがbufferに書き込むまでの間にエラーが発生した場合
* たとえばoverflow_actionがthrow_exception (default) でBufferOverflowErrorが起きるとこのケースに該当します。
  * cf. https://docs.fluentd.org/troubleshooting-guide#my-logs-are-filled-with-bufferoverflow-error
    * file buffer type
    * `flush_interval` is low enough
    * `flush_thread_count` is high enough
      * if you have excessive messages per second and Fluentd is failing to keep adjusting these two settings will increase Fluentd's resource
    * `total_limit_size` is high enough
    * `chunk_limit_size` is high enough

`flush_at_shutdown` がない
* サーバの停止とともにストレージも削除するような設定になっていると、file bufferといえども `flush_at_shutdown` をtrueにしておかなければ、サーバの停止時にflushされていないデータは消失します。

#### `log forwarders` -> `log aggregators` 間での消失
`retry_timeout`, `retry_max_times` の超過
* `log aggregators` が一時的にダウンした場合、`log forwarders` は設定に応じてデータの送信をリトライします。
* `retry_timeout` か `retry_max_times` に到達するまでの間に `log aggregators` が復旧しなければログは消失します。
* もしsecondaryにfile output pluginを指定しておけば、復旧時に手動で `log aggregators` へ送ることもできます。

#### `log aggregators` 内での消失

「`log forwarders` 内での消失」と同様

require_ack_responseがtrueでない
* `require_ack_response` がtrueだと、`log aggregators` はbufferに書き込んだ後、ack responseを返します。
* `log forwarders` はack responseが一定時間内に返ってこなければリトライするので、`log aggregators` のinput threadでエラーが起きた場合やdeadlockで処理できない状態になっている場合でもログは消失しません。
* 一方で、単に `log aggregators` 側の処理で時間がかかっている場合は二重にログを送信してしまうことになります。

#### `log aggregators` →  `log destinations` 間での消失

「`log forwarders` →  `log aggregators` 間での消失」と同様
