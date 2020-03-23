# cargo test

## test with nightly
e.g. using feature like `#![feature(exclusive_range_pattern, arc_unwrap_or_clone)]`

```bash
$ rustup toolchain install nightly
$ cargo +nightly test
```

## テスト中に `print!` とかを stdout へ
```bash
$ cargo test -- --nocapture
```

## parallelism
```bash
$ cargo test -- --test-threads=1
```

## Execute as root
```bash
$ cat > .cargo/config <<EOF
[target.x86_64-unknown-linux-gnu]
runner = 'sudo -E'
EOF
```
