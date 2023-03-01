# Warp with ZTN Setup

## Ubuntu

### Install Cloudflare Root Certs
* https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/user-side-certificates/install-cloudflare-cert/#linux

```bash
$ sudo su -
$ wget https://developers.cloudflare.com/cloudflare-one/static/documentation/connections/Cloudflare_CA.pem -O /usr/local/share/ca-certificates/Cloudflare_CA.crt
$ update-ca-certificates
$ ls /etc/ssl/certs/
```

### Install warp-cli
* https://pkg.cloudflareclient.com/install

```bash
$ sudo su -
$ DIST=`lsb_release -a | tail -1 | awk '{ print $2 }'`
$ curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
$ echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ ${DIST} main" > /etc/apt/sources.list.d/cloudflare-client.list
$ apt update
$ apt install -y cloudflare-warp
```

### Enroll Team by Service Token
* https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/configure-warp/warp-settings/#device-enrollment-permissions
* https://developers.cloudflare.com/cloudflare-one/identity/service-tokens/
* https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/deployment/mdm-deployment/#install-warp-on-linux
* https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/deployment/mdm-deployment/parameters/

```bash
$ cat <<EOF > mdm.xml
<dict>
  <key>organization</key>
  <string>obniz</string>
  <key>auth_client_id</key>
  <string>f7907f8a00a568afd16aa323d35e5352.access</string>
  <key>auth_client_secret</key>
  <string>hogehoge</string>
</dict>
EOF
$ sudo mv mdm.xml /var/lib/cloudflare-warp/mdm.xml

$ warp-cli --accept-tos register
$ warp-cli --accept-tos connect

# verify warp=on
$ curl https://www.cloudflare.com/cdn-cgi/trace/

# when teams-enroll doesnot work
# cf. https://community.cloudflare.com/t/warp-cli-access-client-id-and-access-client-secret-no-longer-exist/384090/3
# 1. Go to https://teamname.cloudflareaccess.com/warp.
# 2. Open DevTools.
# 3. When you get a prompt about opening a link with Cloudflare WARP, press cancel.
# 4. Look at the request to auth?token=<blah> & copy the Request URL that starts with com.cloudflare.warp
# 5. Run warp-cli teams-enroll-token "<paste that Request URL here>"
```

