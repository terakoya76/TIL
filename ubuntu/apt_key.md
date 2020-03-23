# APT
もともと`Debian GNU/Linux`用に開発されたコマンドラインベースのパッケージ管理システムである。現在では多数の `Debian` 系のLinuxディストリビューションで採用されている。
APTには複数のフロントエンドが用意されている。CUIで作動するフロントエンドとして `apt` や `apt-get`、`aptitude` がある。また `Debian` 系や `RPM` 系ともに、`Synaptic` というGUIフロントエンドがある。

## sources.list
APTはリポジトリにあるパッケージをその依存関係にもとづてダウンロードし、システムにインストールするツールである。その「リポジトリ」の情報を管理するのが `sources.list` と呼ばれるファイルである。

### Format
```bash
deb [ option1=value1 option2=value2 ] uri suite [component1] [component2] [...]
deb-src [ option1=value1 option2=value2 ] uri suite [component1] [component2] [...]
```

* `deb` で始まるのはバイナリパッケージ、`deb-src` で始まるのはソースパッケージを提供するリポジトリ。
  * 普段使う分には、バイナリパッケージだけで十分である。ソースパッケージリポジトリを有効化するとそのぶんだけダウンロードするメタデータの情報なども増えてしまう。パッケージングなど特別な理由がない限りは `deb-src` を有効化しなくて良い。
* `suite` には一般的に「リリースのコードネーム」が使われる。
  * たとえば`Ubuntu 20.04 LTS（Focal Fossa）`だと「focal」、`21.04（Hirsute Hippo）`だと「hirsute」。
* `component` はそのリポジトリが複数のコンポーネントに対応しているときに有効なオプション。
  * たとえば`Ubuntu`の場合、そのサポートやライセンスに応じてリポジトリごとに「`main、restricted、universe、multiverse`」の4種類に分かれている。`Debian`にも「`main、contrib、non-free`」が存在する。公式リポジトリのようにコンポーネントに対応したリポジトリを使う場合は、「⁠component」を適切に設定する必要がある。
* optionはいろいろある
  * `arch=amd64,arm64` のように指定すると、そのリポジトリで利用するアーキテクチャを指定できる。
    * 指定しない場合はシステム全体の設定に依存し、`amd64` なマシンなら `amd64` と `i386` を、Raspberry PiのようなARMマシンで32bitなら `armhf⁠`⁠、64bitな `arm64` が使われる。
  * `trusted=yes` を設定すると、リポジトリの署名検証を迂回できる。
    * つまりそのリポジトリを全面的に信用する。ローカルリポジトリのようにパッケージの署名作業をスキップしたい場合に便利。
    * 言い方を変えると「本当に信頼できるパッケージしか置いていないリポジトリ」以外では指定してはいけない。
  * `signed-by=鍵名` では、リポジトリの検証時に利用する鍵をフィンガープリントもしくはファイルパスで指定する。
    * 特定のサードパーティのリポジトリでは、そのサードパーティが提供する鍵を利用する

## APT-key
```bash
$ sudo su -

$ DIST=$(lsb_release -a | tail -1 | awk '{ print $2 }')

$ KEY_NAME=cloudflare-warp-archive-keyring.gpg
$ KEY_PATH=/usr/share/keyrings/${KEY_NAME}

# apt-key is deprecated from ubuntu 20
$ curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output ${KEY_PATH}
$ echo "deb [arch=amd64 signed-by=${KEY_PATH}] https://pkg.cloudflareclient.com/ ${DIST} main" > /etc/apt/sources.list.d/cloudflare-client.list
```
