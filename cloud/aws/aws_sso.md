# AWS SSO

https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html#sso-configure-profile-token-auto-sso

aws-cli v2が入っているか確認。入っていないならupdateする。
cf. https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

```bash
$ aws --version
aws-cli/2.11.10 Python/3.11.2 Linux/5.15.0-69-generic exe/x86_64.ubuntu.22 prompt/off
```

Complete Instruction
```bash
$ aws configure sso
SSO session name (Recommended): my-sso
SSO start URL [None]: https://my-sso-portal.awsapps.com/start
SSO region [None]: us-east-1
SSO registration scopes [None]: sso:account:access

# select account

CLI default client Region [None]: us-west-2<ENTER>
CLI default output format [None]: json<ENTER>
CLI profile name [123456789011_ReadOnly]: my-dev-profile<ENTER>
```
