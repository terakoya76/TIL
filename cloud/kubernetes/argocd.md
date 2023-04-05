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

initial password
```bash
k -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

reset initial password
```bash
# cf. https://github.com/argoproj/argo-cd/blob/master/docs/faq.md#i-forgot-the-admin-password-how-do-i-reset-it
k -n argocd patch secret argocd-secret  -p '{"data": {"admin.password": null, "admin.passwordMtime": null}}'
secret/argocd-secret patched

$ k -n argocd rollout restart deployment/argocd-server
deployment.apps/argocd-server restarted
```
