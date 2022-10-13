# apt-key

```bash
$ sudo su -
$ DIST=$(lsb_release -a | tail -1 | awk '{ print $2 }')
$ KEY_NAME=cloudflare-warp-archive-keyring.gpg
$ KEY_PATH=/usr/share/keyrings/${KEY_NAME}
$ curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output ${KEY_PATH}
$ echo "deb [arch=amd64 signed-by=${KEY_PATH}] https://pkg.cloudflareclient.com/ ${DIST} main" > /etc/apt/sources.list.d/cloudflare-client.list
```
