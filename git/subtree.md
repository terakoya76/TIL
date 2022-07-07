# subtree

add
```bash
# setup subtree test1 in test2
$ pwd
/home/terakoya76/ghq/github.com/terakoya76/test2

$ git remote add test1 https://github.com/terakoya76/test1.git
$ git subtree add --prefix=test1 test1 main
```

push from test2
```bash
$ pwd
/home/terakoya76/ghq/github.com/terakoya76/test2

$ echo "hoge" > test1/hoge.txt
$ git add .
$ git commit -m "from test2"

$ git subtree push --prefix=test1 test1 main
```

push from test1
```bash
$ pwd
/home/terakoya76/ghq/github.com/terakoya76/test1

$ git pull origin main

$ echo "fuga" > fuga.txt
$ git add .
$ git commit -m "from test1"

$ git push origin main
```

pull from test2
```bash
$ pwd
/home/terakoya76/ghq/github.com/terakoya76/test2

$ git subtree pull --prefix=test1 test1 main
```

delete
```bash
$ git filter-branch --tree-filter 'rm -rf test1' HEAD
```

split existed directory as subtree
```bash
$ pwd
/home/terakoya76/ghq/github.com/terakoya76/test2

$ git subtree split --prefix=test1 -b split_test1
$ git checkout split_test1

$ git remote add test3 https://github.com/terakoya76/test3.git
$ git push test3 main
```
