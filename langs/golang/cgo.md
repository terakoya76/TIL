# CGO
Ref: https://golang.org/cmd/cgo/

cgo directive で FLAG 指定
```go
// #cgo CFLAGS: -DPNG_DEBUG=1
// #cgo amd64 386 CFLAGS: -DX86=1
// #cgo LDFLAGS: -lpng
// #include <png.h>
import "C"
```

## GC between C and GO
Ref: https://github.com/shazow/gohttplib/blob/master/ptrproxy.go

go で作った object への pointer を C に渡した場合、go 側で GC が走ると SEGV する。
そのため上記のように、go 側で resource id と pointer の map を作り、C には resource id を渡すといった工夫が必要

## C reference to GO
Ref: https://golang.org/cmd/cgo/#hdr-C_references_to_Go

## GO reference to C
Ref: https://golang.org/cmd/cgo/#hdr-Go_references_to_C

## c-shared と c-archive
Ref: https://golang.org/cmd/go/#hdr-Build_modes

```
-buildmode=c-archive
	Build the listed main package, plus all packages it imports,
	into a C archive file. The only callable symbols will be those
	functions exported using a cgo //export comment. Requires
	exactly one main package to be listed.

-buildmode=c-shared
	Build the listed main package, plus all packages it imports,
	into a C shared library. The only callable symbols will
	be those functions exported using a cgo //export comment.
	Requires exactly one main package to be listed.
```

### Static library 経由で C から GO のコードを実行する
Ref: https://medium.com/@ben.mcclelland/an-adventure-into-cgo-calling-go-code-with-c-b20aa6637e75

### C shared library 経由で多言語から GO のコードを実行する
Ref: https://medium.com/learning-the-go-programming-language/calling-go-functions-from-other-languages-4c7d8bcc69bf

## C library を GO にリンク（C reference to GO）
Ref: https://qiita.com/yugui/items/e71d3d0b3d654a110188

> まずグルーコードを生成する。それからCの世界はCコンパイラ/リンカに任せてすべての依存関係を解決させ、_cgo_.oを作る。次に、_cgo_.oを解析して_cgo_import.goのためのデータを抽出する。
> さらに、その後もGoとCは分離したまま、それぞれ1つずつのオブジェクトファイルにまとめる。そして最後に実行ファイルを作る段になって両者をリンクする。ここでもlibmみたいなCの世界とやりとりする必要があるのでライブラリのロードパスやらはすべてCのリンカに丸投げである。

1. コード生成
  * `go tool cgo import_example.go`
  * `xx.go` ファイル中、cgo を利用しているものだけを cgo コマンドに渡す
2. Cコードのコンパイル（OBJS を生成）
  * `gcc -c SOURCES`
3. Object Files のリンク
  * `gcc -o _cgo_.o OBJS`
4. インポート宣言の生成
  * `go tool cgo -dynimport ....`
  * GO のリンカーに 3. で生成した link 情報（`_cgo_.o`）を渡す
5. Goコードのコンパイル
  * `go tool compile -o example1.a -pack GO_FILES`
  * 1,4 で生成した GO Files および cgo を利用していないものをコンパイル
6. Cコードの再リンク
  * `gcc -o _all.o OBJS`
  * 3. との違いは依存ライブラリは link しないこと
7. Cオブジェクトをアーカイブに追加
  * `go tool pack r example1.a _all.o`
  * 6. で生成した link 情報を 5. で生成したアーカイブに追加
8. アーカイブ内のオブジェクトをリンク
  * `go tool link -o example example1.a`
  * アーカイブ内の Object や依存ライブラリの Object をリンクする

## C library を GO にリンク（GO reference to C）
Ref: https://qiita.com/yugui/items/cc490d080e0297251090
