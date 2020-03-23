# submodule

add
```bash
$ git submodule add <url> <local_path>
```

update
```bash
$ git submodule update
```

del
```bash
$ git submodule deinit -f <submodule_name>
$ git rm -f <submodule_name>
$ rm -rf .git/modules/<submodule_name>
```
