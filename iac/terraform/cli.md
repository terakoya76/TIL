# terraform cli

## parallelism
```bash
export TF_CLI_ARGS_plan="--parallelism=50"
export TF_CLI_ARGS_apply="--parallelism=50"
```

## env
vars via env
```bash
$ export TF_VAR_client_id="hoge"
$ export TF_VAR_client_secret="fuga"
```
