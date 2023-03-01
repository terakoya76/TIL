# iostat

## Summary

```bash
$ iostat -dxz 1
Linux 5.4.0-54-generic (ubuntu-focal)   01/03/21        _x86_64_        (2 CPU)

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz  aqu-sz  %util
loop0            0.02      0.22     0.00   0.00    0.45    13.71    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00   0.00
loop1            0.34      0.40     0.00   0.00    0.64     1.18    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00   0.01
loop2            4.02      4.08     0.00   0.00    0.20     1.02    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00   0.04
loop3            0.03      1.63     0.00   0.00    0.07    54.74    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00   0.00
sda              4.49    165.92     0.96  17.62    0.43    36.96    8.82   1165.59     6.80  43.54    2.20   132.22    0.00      0.00     0.00   0.00    0.00     0.00    0.01   0.84
sdb              0.07      0.66     0.00   0.00    0.21     9.88    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00   0.00
```

### Option
* `-d` disk utilization
* `-x` extended column
* `-z` skipping devices w/ zero metrics

### Result
* `rrqm/s` read request queued and merged per second
* `wrqm/s` write request queued and merged per second
* `r/s` read requests completed per second (after merges)
* `w/s` writes requests completed per second (after merges)
* `rkB/s` Kbytes read from the disk device per second
* `wkB/s` Kbytes write from the disk device per second
