## Add Metadata to JSON
```bash
attach_metadata() {
    cat - \
          EXPORTED_AT="$(date '+%s' | awk '{print strftime("%Y-%m-%d %H:%M:%S", $1)}')" \
          jq '. |= .+ {"exported_at": env.EXPORTED_AT}'
}
```
