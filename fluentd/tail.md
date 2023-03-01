# Tail Plugin

## Summary
Ref: https://debug-life.net/entry/996

### tail -F
* `tail -F` に類似した振る舞いをする
  * `tail -f` でなく `tail -F`
  * -Fオプションでは、tailはファイルのrenameやrotateを追跡し、inode numberが変わった場合はファイルをreopenし、tailを再開してくれる
* tail開始時、デフォルトではtail対象のファイルの先頭でなく末尾からデータの読み込みを開始する
* positionファイルを指定することでtailしていたファイルの最終の読み込み位置（pos）を記録し、次回開始時にpos以降のデータから読み込みを開始する

### Basic Behavior
* NewTailInputは、Fluentd起動時に`refresh_interval`の間隔で発行されるTimerイベントを生成し、`Cool.io` のイベントループに登録する
* その後はrefresh_intervalごとにTimerイベントが通知され、refresh_watchersメソッドが呼び出される
  * その中で、既存の古いwatcherの停止や新しくtailに追加されるパスのファイルを監視するためのTailWatcherを新しくセットアップする
* TailWatcherは各パスに対して生成され、初期化時にデフォルトで1secごとのTimerイベント、Statイベントおよびファイルローテートのためのハンドラなどが割り当てられる
* TailWatcherのTimerおよびStatのイベントが通知されるとTailWatcher#on_notifyメソッドが呼ばれ、登録された各種ハンドラが呼び出される
* パスのファイルに読み取るべきデータがあれば、IOHandlerによって1回の処理で最大行数がread_lines_limitを超えないようバッファされ、parserによってパースされ、tag付けされイベントとしてemitされる

### rotate 判定
* pos_fileのinodeと新しく検出されたファイルのinode番号が同じ場合は下記とみなしpos_fileに記録されていたposから読み込みを開始する
  * 1) renameした後元に戻された
  * 2) 同じファイルに対するシンボリックリンク・ハードリンクが再作成された
* pos_fileにあるinode番号が0でない場合、pos_fileを指定しFluentdを以前に起動していたケースと想定し、rotateされたファイルの先頭からデータの読み込みを開始する
* 上記以外の場合、read_from_headがtrueであればファイルの先頭から、そうでない場合はファイルの末尾からデータの読み込みを開始する

