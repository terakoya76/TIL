# TFC resource count

```bash
org=xxx

for ws in $(curl -s \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/vnd.api+json" \
  https://app.terraform.io/api/v2/organizations/${org}/workspaces \
  | jq -r .data[].attributes.name | sort); do

  url="https://app.terraform.io$(curl -s \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Content-Type: application/vnd.api+json" \
    "https://app.terraform.io/api/v2/organizations/${org}/workspaces/${ws}" \
    | jq -r '.data.links."self-html"')"

  count=$(curl -s \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Content-Type: application/vnd.api+json" \
    "https://app.terraform.io/api/v2/state-versions?filter%5Borganization%5D%5Bname%5D=${org}&filter%5Bworkspace%5D%5Bname%5D=${ws}" \
    | jq '[.data[0] | if has("attributes") then (.attributes.providers[] | add) else 0 end] | add ')

  echo "${ws},${count},${url}"
done
```
