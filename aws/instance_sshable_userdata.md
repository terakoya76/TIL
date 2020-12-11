## instanct sshable userdata
Ref: https://aws.amazon.com/jp/premiumsupport/knowledge-center/ec2-user-account-cloud-init-user-data/

```bash
#cloud-config
cloud_final_modules:
- [users-groups,always]
users:
  - name: <username>
    groups: [ wheel ]
    sudo: [ "ALL=(ALL) NOPASSWD:ALL" ]
    shell: /bin/bash
    ssh-authorized-keys:
    - ssh-rsa AB3nzExample
```
