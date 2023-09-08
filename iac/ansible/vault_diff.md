# Vault Diff

```bash
PR_NUMBER=100
BASE_BRANCH_NAME="origin/main"
REMOTE_BRANCH_NAME="pull/${PR_NUMBER}/head"

git fetch origin ${REMOTE_BRANCH_NAME}:${PR_NUMBER}
for f in $(git diff --diff-filter=d --name-only ${BASE_BRANCH_NAME} ${PR_NUMBER}); do

  echo "==============================================================================="
  echo "filename: ${f}"
  echo "==============================================================================="

  diff -uw \
    <(ansible-vault view <(git show ${BASE_BRANCH_NAME}:${f} 2>/dev/null) 2>/dev/null || git show ${BASE_BRANCH_NAME}:${f} 2>/dev/null || echo "") \
    <(ansible-vault view <(git show ${PR_NUMBER}:${f} 2>/dev/null) 2>/dev/null || git show ${PR_NUMBER}:${f} 2>/dev/null || echo "")

  echo ""
done
```
