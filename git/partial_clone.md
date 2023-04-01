# Partial Clone
Ref: https://github.blog/jp/2021-01-13-get-up-to-speed-with-partial-clone-and-shallow-clone/

## Partial Clone

### Blob-LESS Clone
このcloneは、到達可能なすべてのcommitとtreeをダウンロードする一方、blobは必要に応じて取得します。
開発者や複数回ビルドを実行するようなビルド環境に最適です。

```bash
$ git clone --filter=blob:none git@github.com:terakoya76/TIL.git
```

### Tree-LESS Clone
このcloneは、到達可能なすべてのcommitをダウンロードする一方、treeとblobは必要に応じて取得します。
一度ビルドを実行した後に削除される予定で、`git log` や、`git merge-base` など、commit履歴にはアクセスしたいというビルド環境に最適です。


```bash
$ git clone --filter=tree:0 git@github.com:terakoya76/TIL.git
```

## Shallow Clone
このcloneはcommit履歴を切り捨てcloneのサイズを小さくします。
これによって、想定外の問題を引き起こしたり、利用可能なGitコマンドが制限されたりします。
後からのfetchに過度のストレスを与えることになるので、開発者が使用することは強くお勧めしません。一度ビルドした後にリポジトリを削除するビルド環境では便利です。

```bash
$ git clone --depth=1 git@github.com:terakoya76/TIL.git
```

Shallow Cloneは `--single-branch --branch=<branch>` オプションと組み合わせることで、確実にすぐ使う予定のコミットのデータのみをダウンロードできます。

## sparse-checkout

特定のディレクトリをDLしたい

```bash
$ git clone --filter=blob:none --no-checkout git@github.com:terakoya76/TIL.git
$ cd TIL
$ git sparse-checkout set --CONE /docker
$ git checkout
```
