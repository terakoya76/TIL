# ArgoCD CLI

login
```bash
# login
argocd login --grpc-web <cd.argoproj.io>

# SSO
argocd login --grpc-web --sso <cd.argoproj.io>
```

diff
```bash
# list app
argocd app list

# take a diff with a given revision
argocd app diff <app-name> --revision <commit-hash>
```
