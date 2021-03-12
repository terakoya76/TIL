## Tail Plugin

### Summary
Ref: https://debug-life.net/entry/996

#### tail -F
* `tail -F` に類似した振る舞いをする
  * `tail -f` でなく `tail -F`
  * -F オプションでは、tail はファイルの rename や rotate を追跡し、inode number が変わった場合はファイルを reopen し、tail を再開してくれる
* tail 開始時、デフォルトでは tail 対象のファイルの先頭でなく末尾からデータの読み込みを開始する。
* position ファイルを指定することで tail していたファイルの最終の読み込み位置（pos）を記録し、次回開始時に pos 以降のデータから読み込みを開始する。

#### Basic Behavior
* NewTailInput は、fluentd 起動時に refresh_interval で指定された間隔で発火される Timer イベントを生成し、`Cool.io` のイベントループに登録する。
* その後は refresh_interval ごとに Timer イベントが通知され、refresh_watchers メソッドが呼び出される。
  * その中で、既存の古い watcher の停止や新しく tail に追加される path のファイルを監視するための TailWatcher を新しくセットアップする。
* TailWatcher は1つ1つの path に対して生成され、初期化時にデフォルトで1secごとの Timer イベント、Stat イベント及びファイルローテートのためのハンドラなどが割り当てられる。
* TailWatcher の Timer 及び Stat のイベントが通知されると TailWatcher#on_notify メソッドが呼ばれ、登録された各種ハンドラが呼び出される。
* path のファイルに読み取るべきデータがあれば、IOHandler によって一回の処理で最大行数が read_lines_limit を超えないようバッファされ、parser によってパースされ、tag 付けされイベントとして emit される。

#### rotate 判定
* pos_file の inode と新しく検出されたファイルの inode 番号が同じ場合は下記とみなし pos_file に記録されていた pos から読み込みを開始する。
  * 1) renameした後元に戻された、
  * 2) 同じファイルに対するシンボリックリンク・ハードリンクが再作成された、
* pos_file にある inode 番号が0でない場合、pos_file を指定し fluentd を以前に起動していたケースと想定し、rotate されたファイルの先頭からデータの読み込みを開始する。
* 上記以外の場合、read_from_head が true であればファイルの先頭から、そうでない場合はファイルの末尾からデータの読み込みを開始する。

