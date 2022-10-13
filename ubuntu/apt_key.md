# apt
もともと Debian 用に開発されたコマンドラインベースのパッケージ管理システムである。現在では多数の Debian 系の Linux ディストリビューションで採用されている。
APT には複数のフロントエンドが用意されている。CUI で作動するフロントエンドとして apt や apt-get、aptitude がある。また Debian 系や RPM 系ともに、Synaptic という GUI フロントエンドがある。

## sources.list
Apt はリポジトリにあるパッケージをその依存関係に基づいてダウンロードし、システムにインストールするツールです。その「リポジトリ」の情報を管理するのが `sources.list` と呼ばれるファイルとなります。

### Format
```
deb [ option1=value1 option2=value2 ] uri suite [component1] [component2] [...]
deb-src [ option1=value1 option2=value2 ] uri suite [component1] [component2] [...]
```

* `deb` で始まるのはバイナリパッケージ、`deb-src` で始まるのはソースパッケージを提供するリポジトリです。
  * 普段使う分には、バイナリパッケージだけで十分です。ソースパッケージリポジトリを有効化するとその分だけダウンロードするメタデータの情報なども増えてしまいます。パッケージングなど特別な理由がない限りは `deb-src` を有効化しなくて良いでしょう。
* `suite` には一般的に「リリースのコードネーム」が使われます。
  * たとえばUbuntu 20.04 LTS（Focal Fossa）だと「focal」ですし、21.04（Hirsute Hippo）だと「hirsute」です。
* `component` はそのリポジトリが複数のコンポーネントに対応しているときに有効なオプションです。
  * たとえばUbuntuの場合、そのサポートやライセンスに応じてリポジトリごとに「main、restricted、universe、multiverse」の4種類にわかれています。Debianにも「main、contrib、non-free」が存在します。公式リポジトリのようにコンポーネントに対応したリポジトリを使う場合は、「⁠component」を適切に設定しましょう。
* option は色々有り
  * `arch=amd64,arm64` のように指定すると、そのリポジトリで利用するアーキテクチャーを指定できます。
    * 指定しない場合はシステム全体の設定に依存し、`amd64` なマシンなら `amd64` と `i386` を、Raspberry Pi のような ARM マシンで 32bit なら `armhf⁠`⁠、64bitな `arm64` が使われます。
  * `trusted=yes` を設定すると、リポジトリの署名検証を迂回できます。
    * つまりそのリポジトリを全面的に信用します。ローカルリポジトリのようにパッケージの署名作業をスキップしたい場合に便利です。
    * 言い方を変えると「本当に信頼できるパッケージしか置いていないリポジトリ」以外では指定してはいけません。
  * `signed-by=鍵名` では、リポジトリの検証時に利用する鍵をフィンガープリントもしくはファイルパスで指定します。
    * 特定のサードパーティのリポジトリでは、そのサードパーティが提供する鍵を利用します

## apt-key
```bash
$ sudo su -

$ DIST=$(lsb_release -a | tail -1 | awk '{ print $2 }')

$ KEY_NAME=cloudflare-warp-archive-keyring.gpg
$ KEY_PATH=/usr/share/keyrings/${KEY_NAME}

# apt-key is deprecated from ubuntu 20
$ curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output ${KEY_PATH}
$ echo "deb [arch=amd64 signed-by=${KEY_PATH}] https://pkg.cloudflareclient.com/ ${DIST} main" > /etc/apt/sources.list.d/cloudflare-client.list
```
