## move repo with history

```bash
$ git clone git@github.com:terakoya76/hoge.git
$ cd hoge
$ git filter-branch -f  --subdirectory-filter subdir_name -- --all
$ git remote add new-repo git@github.com:terakoya76/subdir_name.git
$ git push new-repo master
```
