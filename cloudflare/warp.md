# Warp with ZTN Setup

## Ubuntu

Install warp-cli
- https://pkg.cloudflareclient.com/install

```bash
$ curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg

$ echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ jammy main' | sudo tee /etc/apt/sources.list.d/cloudflare-client.list

$ sudo apt update

$ sudo apt install -y cloudflare-warp
```

Enroll Team
- https://developers.cloudflare.com/warp-client/get-started/linux/
- https://community.cloudflare.com/t/cloudflare-teams-warp-for-linux-enrollment/350857

```bash
$ warp-cli register

$ warp-cli connect

# verify warp=on
$ curl https://www.cloudflare.com/cdn-cgi/trace/

$ warp-cli enable-always-on

$ warp-cli teams-enroll <team-name>

# when teams-enroll doesnot work
# cf. https://community.cloudflare.com/t/warp-cli-access-client-id-and-access-client-secret-no-longer-exist/384090/3
# 1. Go to https://teamname.cloudflareaccess.com/warp.
# 2. Open DevTools.
# 3. When you get a prompt about opening a link with Cloudflare WARP, press cancel.
# 4. Look at the request to auth?token=<blah> & copy the Request URL that starts with com.cloudflare.warp
# 5. Run warp-cli teams-enroll-token "<paste that Request URL here>"
```

Install Cloudflare Root Certs
- https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/install-cloudflare-cert#linux

```bash
$ wget https://developers.cloudflare.com/cloudflare-one/static/documentation/connections/Cloudflare_CA.pem -O Cloudflare_CA.pem
$ sudo cp Cloudflare_CA.pem /usr/local/share/ca-certificates/Cloudflare_CA.crt
$ sudo dpkg-reconfigure ca-certificates

$ ls /etc/ssl/certs/
```
