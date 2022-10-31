# Partial Clone
Ref: https://github.blog/jp/2021-01-13-get-up-to-speed-with-partial-clone-and-shallow-clone/

## Partial Clone

### Blob Less Clone
この clone は、到達可能なすべての commit と tree をダウンロードする一方、blob は必要に応じて取得します。
この clone は、開発者や複数回ビルドを実行するようなビルド環境に最適です。

```bash
$ git clone --filter=blob:none git@github.com:terakoya76/TIL.git
```

### Tree Less Clone
この clone は、到達可能なすべての commit をダウンロードする一方、tree と blob は必要に応じて取得します。
この clone は、一度ビルドを実行した後に削除される予定で、`git log` や、`git merge-base` など、commit 履歴にはアクセスしたいというビルド環境に最適です。


```bash
$ git clone --filter=tree:0 git@github.com:terakoya76/TIL.git
```

## Shallow Clone
この clone は commit 履歴を切り捨てて clone のサイズを小さくします。これによって、想定外の問題を引き起こしたり、利用可能な Git コマンドが制限されます。
また、この clone は後からの fetch に過度のストレスを与えることになるので、開発者が使用することは強くお勧めしません。一度ビルドした後にリポジトリを削除するビルド環境では便利です。

```bash
$ git clone --depth=1 git@github.com:terakoya76/TIL.git
```

Shallow Clone は `--single-branch --branch=<branch>` オプションと組み合わせることで、確実にすぐに使う予定のコミットのデータのみをダウンロードすることができます。

## sparse-checkout

特定のディレクトリをDLしたい

```bash
$ git clone --filter=blob:none --no-checkout git@github.com:terakoya76/TIL.git
$ cd TIL
$ git sparse-checkout set --CONE /docker
$ git checkout
```
