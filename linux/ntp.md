## NTP

cf. https://milestone-of-se.nesuke.com/l7protocol/ntp/ntp-summary/

### NTP とは
IP 機器が自動で時間を調整するために使うプロトコル

### Startum
時計からの距離
* 原子時計や GPS 等の高信頼性の時計自体を Stratum 0と定義する
* startum 0 と (ネットワーク越しではなく) 物理的に直結している NTP server が Stratum 1 となる
  * Stratum 1 の NTP server を Primary と呼ぶ
* Primary server から NTP プロトコルを使って時刻同期する機器の Stratum は 2 となり、以降同様に NTP で時刻同期をとるたびに Stratum が 1 ずつ増える
  * Stratum 2～15 の NTP server を Secondary server と呼ぶ
  * 16以上は信頼できない時刻ソースとされ、利用できない

### Protocol
複数台の NTP server から時刻を取得し、まずは明らかに時刻の外れているものがあればそれを除外します。
そして次に残った時刻ソースから、精度が高いと思われるものを3つ選び、それを使って時刻修正を行います

NTP では server からもらった時刻をそのまま設定することはない。
パケットのやり取りの中で、sevrer の処理遅延や NW 遅延、NW のゆらぎ (Jitter) の統計を取り、精度の高い時刻を計算して返す
* Reference Timestamp
  * 最後に複数の NTP server を元に同期した時刻
* Origin Timestamp
  * NTP client/server が受け取った packet の Transmit Timestamp が入る
  * 先行する packet の Transmit Timestamp
* Receive Timestamp
  * NTP client/server が packet を受信した時間を示す timestamp
* Transmit Timestamp
  * NTP client/server が packet を投げた時間を示す timestamp

これらの timestamp から下記統計情報を管理する
* client/sever 間の NW 遅延
  * `Receive Timestamp - Origin Timestamp`
    * 「自分が受け取った時刻」から「対向が送信した時刻」を引いたものが NW 遅延になる
  * 厳密には client/server 間で基準時間にずれがあるのが自然なので、NW 遅延には client 基準時間と server 基準時間のズレも含まれる
    * そのため、この timestamp だけで、NW の品質と基準時間両方を考慮した時刻差を導出できる
* offset（時刻差）
  * 「server から見た NW 遅延」から「client から見た NW 遅延」を引いて2で割る
  * NW 上の転送が行き帰りで同じ速さであるとすると、NW 遅延は実質 client/server 間の基準時間差を示すことに成る
* RTT（往復時間）
  * 「server から見た NW 遅延」と「client から見た NW 遅延」を足す
