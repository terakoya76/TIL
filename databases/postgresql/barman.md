# Barman

Ref: https://github.com/EnterpriseDB/barman


## PITR
Ref: https://www.sraoss.co.jp/tech-blog/pgsql/barman/

機能
* PostgreSQL の PITR（ベースバックアップと WAL アーカイビング）を基にしている。
* ベースバックアップは ssh + rsync や pg_basebackup が使える。
* WAL アーカイビングは archive_command やストリーミングレプリケーションプロトコルが使える。
* フルバックアップのインクリメンタルバックアップができる。
* バックアップ・WAL の取得前後にフックスクリプトを呼び出せる。
* ネットワーク制限・データ転送の圧縮・WAL の圧縮・並行ジョブの実施によってワークロードを調整できる。
* 複数のデータベースクラスタのバックアップを Barman でまとめて管理できる。
* 世代管理などのバックアップポリシーを規定できる

### Configure Barman
設定ファイルは INI 形式

Target
* Barman 自体
  * Barman 自体のグローバル設定は `/etc/barman.conf` で行います。
* 管理対象のサーバ情報
  * 管理対象サーバー設定は `/etc/barman.d/xxx.conf` で行います。


 ```ini
# /etc/barman.conf
barman_user = postgres
barman_home = /var/lib/pgsql


# /etc/barman.d/pgsql01.conf
[ssh-pgsql01]
ssh_command = ssh -q postgres@pgsql01
conninfo = host=pgsql01 user=postgres dbname=postgres
backup_method = rsync ; ベースバックアップは rsync で行なう
archiver = on ; archive_command による WAL アーカイビング

[streaming-pgsql01]
conninfo = host=pgsql01 user=postgres dbname=postgres port=5433
backup_method = postgres ; ベースバックアップは pg_basebackup で行なう
streaming_archiver = on ; ストリーミングレプリケーションプロトコルによる WAL アーカイビング
slot_name = barman ; レプリケーションスロットを使う（streaming_archiver = on の場合に推奨）
 ```
