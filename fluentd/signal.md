## Signal
Ref: https://docs.fluentd.org/deployment/signals

### SIGINT or SIGTERM
* daemon が graceful stop する。
* Fluentd は、メモリバッファ全体を一度にフラッシュしようとしますが、フラッシュに失敗しても再試行しません。
* Fluentd はファイルバッファをフラッシュしません。デフォルトでは、ログはディスクに保存されます。

### SIGUSR1
* バッファリングされたメッセージを強制的にフラッシュし、Fluentd のログを再オープンします。
* Fluentdは、現在のバッファ（メモリとファイルの両方）を直ちにフラッシュしようとし、flush_interval でフラッシュを続けます。

### SIGUSR2
* データ・パイプラインを graceful に再構築することで、設定ファイルを再ロードします。
* Fluentd は、メモリバッファ全体を一度にフラッシュしようとしますが、フラッシュに失敗しても再試行しません。
* Fluentd はファイルバッファをフラッシュせず、デフォルトではログをディスクに保存します。
* This signal has been supported since v1.9.0.

### SIGHUP
* ワーカープロセスを graceful に再起動することで、設定ファイルをリロードします。
* Fluentd は、メモリバッファ全体を一度にフラッシュしようとしますが、フラッシュに失敗しても再試行しません。
* Fluentd はファイルバッファをフラッシュせず、デフォルトではログをディスクに保存します。
* If you use fluentd v1.9.0 or later, use SIGUSR2 instead.

### SIGCONT
* Calls SIGDUMP to dump fluentd internal status.
