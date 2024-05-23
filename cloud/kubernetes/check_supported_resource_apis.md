# Check Supported Resource API Versions

```bash
function api_status() {
  local prefix=$1
  local gvr=$2
  if kubectl get --raw "${prefix}/${gvr}" 2>&1 | grep -E "^Warning:" > /dev/null; then
    echo "${gvr} D"
  else
    echo "${gvr}"
  fi
}

for r in $(kubectl get --raw "/api/v1" | jq -r '.resources[].name | select (. | contains("/") | not)'); do
  api_status "/api" "v1/${r}"
done
for gv in $(kubectl get --raw "/apis" | jq -r '.groups[].versions[].groupVersion'); do
  for r in $(kubectl get --raw "/apis/${gv}" | jq -r '.resources[].name | select (. | contains("/") | not)'); do
    api_status "/apis" "${gv}/${r}"
  done
done
```
