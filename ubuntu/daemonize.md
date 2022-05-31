# daemonize script

```bash
$ nohup $EXEC_SCRIPT 0<&- &> $LOG_FILE & echo $! > $PID_FILE
```

* `nohup` catches the hungup signal
* `<&-` close fd (this case fd 0 which is stdin)
* `&>` redirect both of stdout/stderr
* `$!` PID of the most last background command
