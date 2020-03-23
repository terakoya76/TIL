# move repo with history

single sub-directory
```bash
git clone git@github.com:terakoya76/original.git
cd original

git filter-branch -f --subdirectory-filter subdir_path -- --all

git remote add new git@github.com:terakoya76/new.git
git push new master
```

multi sub-directory
cf. https://stackoverflow.com/questions/2982055/detach-many-subdirectories-into-a-new-separate-git-repository
```bash
git clone git@github.com:terakoya76/original.git
cd original

GIT_COMMIT=HEAD
# git rm --cached = file を管理対象から外す
#   -q = quiet
#   -r = directory recursive
#   --ignore-unmatch = exit 0 even if no files matched
# git reset = GIT_COMMIT 時点に戻す
#   -q = quiet
git filter-branch \
  --index-filter 'git rm --cached -qr --ignore-unmatch -- . && git reset -q $GIT_COMMIT -- subdir_path1 subdir_path2' \
  --prune-empty \
  -- --all

git remote add new git@github.com:terakoya76/new.git
git push new master
```
