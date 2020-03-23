# NTP

cf. https://milestone-of-se.nesuke.com/l7protocol/ntp/ntp-summary/

## NTP とは
IP機器が自動で時間を調整するために使うプロトコル

## Startum
時計からの距離
* 原子時計やGPS等の高信頼性の時計自体をStratum 0と定義する
* startum 0と（ネットワーク越しではなく）物理的に直結しているNTP serverがStratum 1となる
  * Stratum 1のNTP serverをPrimaryと呼ぶ
* Primary serverからNTPプロトコルを使って時刻同期する機器のStratumは2となり、以降同様にNTPで時刻同期をとるたびにStratumが1ずつ増える
  * Stratum 2～15のNTP serverをSecondary serverと呼ぶ
  * 16以上は信頼できない時刻ソースとされ、利用できない

## Protocol
複数台のNTP serverから時刻を取得し、まずは明らかに時刻の外れているものがあればそれを除外します。
そして次に残った時刻ソースから、精度が高いと思われるものを3つ選び、それを使って時刻修正します。

NTPではserverからもらった時刻をそのまま設定することはない。
パケットのやりとりの中で、sevrerの処理遅延やNW遅延、NWのゆらぎ (Jitter) の統計を取り、精度の高い時刻を計算して返す
* `Reference Timestamp`
  * 最後に複数のNTP serverを元に同期した時刻
* `Origin Timestamp`
  * NTP client/serverが受け取ったpacketの`Transmit Timestamp`が入る
  * 先行するpacketの`Transmit Timestamp`
* `Receive Timestamp`
  * NTP client/serverがpacketを受信した時間を示すタイムスタンプ
* `Transmit Timestamp`
  * NTP client/serverがpacketを投げた時間を示すタイムスタンプ

これらのタイムスタンプから下記統計情報を管理する
* client/sever間のNW遅延
  * `Receive Timestamp - Origin Timestamp`
    * 「自分が受け取った時刻」から「対向が送信した時刻」を引いたものがNW遅延になる
  * 厳密には、client/server間で基準時間はずれているのが自然ですので、NW遅延にはclient基準時間とserver基準時間のズレも含まれる
    * そのため、このタイムスタンプだけで、NWの品質と基準時間両方を考慮した時刻差を導出できる
* offset（時刻差）
  * 「serverから見たNW遅延」から「clientから見たNW遅延」を引いて2で割る
  * NW上の転送が行き帰りで同じ速さであるとすると、NW遅延は実質client/server間の基準時間差を示すことに成る
* RTT（往復時間）
  * 「serverから見たNW遅延」と「clientから見たNW遅延」を足す
