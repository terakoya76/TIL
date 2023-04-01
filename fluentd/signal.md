# Signal
Ref: https://docs.fluentd.org/deployment/signals

## SIGINT or SIGTERM
* daemonがgraceful stopする。
* Fluentdは、メモリバッファ全体を一度にflushしようとしますが、flushに失敗しても再試行しません。
* Fluentdはファイルバッファをflushしません。デフォルトでは、ログはディスクに保存されます。

## SIGUSR1
* バッファリングされたメッセージを強制的にflushし、Fluentdのログを再オープンします。
* Fluentdは、現在のバッファ（メモリとファイルの両方）をただちにflushしようとし、`flush_interval` でflushを続けます。

## SIGUSR2
* データ・パイプラインをgracefulに再構築することで、設定ファイルを再ロードします。
* Fluentdは、メモリバッファ全体を一度にflushしようとしますが、flushに失敗しても再試行しません。
* Fluentdはファイルバッファをflushせず、デフォルトではログをディスクに保存します。
* v1.9.0 以降からサポート開始。

## SIGHUP
* ワーカプロセスをgracefulに再起動することで、設定ファイルをリロードします。
* Fluentdは、メモリバッファ全体を一度にflushしようとしますが、flushに失敗しても再試行しません。
* Fluentdはファイルバッファをflushせず、デフォルトではログをディスクに保存します。
* luentd v1.9.0以降のバージョンを利用の場合は `SIGUSR2` を利用すること。

## SIGCONT
* Calls SIGDUMP to dump Fluentd internal status.
