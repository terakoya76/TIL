# Simple Semaphore with dynamodb

```bash
lock_table_name=lock_table
lock_table_hash_key=lock_key
lock_val=my_ip
lock_table_ttl_key=expired_at
lock_table_ttl=600

function take_lock {
  for i in $(seq 1 20); do
    aws dynamodb put-item \
      --table-name ${lock_table_name} \
      --item "{\"${lock_table_hash_key}\": {\"S\": \"${lock_val}\"}}, \"${lock_table_ttl_key}\": {\"N\": \"$(date -d \"${lock_table_ttl} seconds\" +%s)\"}}" \
      --condition-expression "attribute_not_exists(${lock_table_hash_key}) OR ${lock_table_ttl_key} < :timestamp" \
      --expression-attribute-values "{\":timestamp\": {\"N\": \"$(date +%s)\"}}"
    local result=$?
    if [ $result -eq 0 ]; then
      return 0
    fi

    sleep 30
  done

  return 1
}

function release_lock {
  aws dynamodb delete-item \
    --table-name ${lock_table_name} \
    --key "{\"${lock_table_hash_key}\": {\"S\": \"${lock_val}\"}}"
  local result=$?
  if [ $result -eq 0 ]; then
    return 0
  fi

  return 1
}
```
