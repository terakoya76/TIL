## docker-compose w/ ECR image
Ref: https://docs.aws.amazon.com/ja_jp/AmazonECR/latest/userguide/common-errors-docker.html

```bash
$ aws ecr get-login-password | docker login --username AWS --password-stdin https://xxxxx.dkr.ecr.ap-northeast-1.amazonaws.com

$ docker-compose pull
Pulling db              ... done
Pulling redis           ... done
Pulling auth            ... error

ERROR: for auth Get https://xxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/v2/auth/manifests/latest: no basic auth credentials
```

原因は region の指定をして認証を行っていないこと

```bash
$ aws ecr get-login-password  --region ap-northeast-1 | docker login --username AWS --password-stdin https://xxxxx.dkr.ecr.ap-northeast-1.amazonaws.com
```
