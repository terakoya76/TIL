# Tips for GitHub api

Pick up random member from teams
```bash
# fetch all members from team
$ hub api "orgs/<org-name>/teams/<team-slug>/members"

# random pick
members=$(hub api "orgs/<org-name>/teams/<team-slug>/members")
$ n=$(echo ${members} | jq '. | length')
$ echo ${members} | jq --arg i $(($RANDOM % ${n})) '.[$i|tonumber].login'
```
