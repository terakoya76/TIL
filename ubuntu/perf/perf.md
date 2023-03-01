# Perf

## Install
```bash
$ sudo apt install linux-tools-`uname -r`
```

## Basic Usage

```bash
# specific process
$ sudo perf record -F 99 -p $(pgrep warp-svc) -g dwarf -- sleep 10

# specific CPU (CPU-0)
$ sudo perf record -F 99 -C 0 -g dwarf -- sleep 10

# same as `sudo perf report --stdio -i ./perf.data`
$ sudo perf report --stdio
```

* -a: すべてのCPUのデータを採取します（デフォルトの動作）。
* -C/--cpu (cpu number): 採取するデータを、指定したCPUのデータに限定します。
* -g/--call-graph: バックトレース情報も採取します。
* -o (file name): 出力ファイル名を指定します（デフォルト：perf.data）。


## Supported Arch
`perf mem` はIntel CPUのみ対応している模様
https://community.amd.com/t5/server-gurus-discussions/issues-with-perf-mem-record/m-p/95270

## Allow non-root user perf usage
cf. https://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/focal/commit/?id=2986a639d3181e4686c5b88303a54f439d33c34a

```c
// kernel/events/core.c

/*
 * perf event paranoia level:
 *  -1 - not paranoid at all
 *   0 - disallow raw tracepoint access for unpriv
 *   1 - disallow cpu events for unpriv
 *   2 - disallow kernel profiling for unpriv
 *   4 - disallow all unpriv perf event use
 */
```

```bash
sudo sh -c 'echo -1 >/proc/sys/kernel/perf_event_paranoid'
```
