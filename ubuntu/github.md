# GitHub


## List PR Authors
```bash
#!/bin/bash

repo=$1
filepath=$2
page=1
per_page=100

end_flag=0

echo "" > ${filepath}
while [ "${end_flag}" -eq 0 ]
do
    str=$(curl \
        -H "Accept: application/vnd.github.v3+json"  \
        -H "Authorization: token ${GITHUB_PRIVATE_ACCESS_TOKEN}" \
        "https://api.github.com/repos/$repo/pulls?state=all&per_page=${per_page}&page=${page}" | jq .[].user.login)

    arr=(${str})
    for i in ${arr[@]}; do
        echo "${i}" >> "${filepath}"
    done

    echo "result: ${arr[@]}"
    echo "result size: ${#arr[@]}"
    if [ "${#arr[@]}" -lt "${per_page}" ]; then
        end_flag=1
    else
        page=$((page+1))
    fi
done

cat "${filepath}" | sort | uniq
```

## List Issues Authors
```bash
#!/bin/bash

repo=$1
filepath=$2
page=1
per_page=100

end_flag=0

echo "" > ${filepath}
while [ "${end_flag}" -eq 0 ]
do
    str=$(curl \
        -H "Accept: application/vnd.github.v3+json"  \
        -H "Authorization: token ${GITHUB_PRIVATE_ACCESS_TOKEN}" \
        "https://api.github.com/repos/$repo/issues?state=all&per_page=${per_page}&page=${page}" | jq .[].user.login)

    arr=(${str})
    for i in ${arr[@]}; do
        echo "${i}" >> "${filepath}"
    done

    echo "result: ${arr[@]}"
    echo "result size: ${#arr[@]}"
    if [ "${#arr[@]}" -lt "${per_page}" ]; then
        end_flag=1
    else
        page=$((page+1))
    fi
done

if [ -f "${filepath}" ]; then
    cat "${filepath}" | sort | uniq
fi
```
