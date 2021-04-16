## json logging
```bash
function logging() {
    local msg=$1
    local ts=$(date '+%Y-%m-%dT%H:%M:%S%z')
    echo $(cat <<EOS
{
  "level": "INFO",
  "message": "${msg}"
  "time": "${ts}"
}
EOS
) >> ${LOGFILE}
}
```
