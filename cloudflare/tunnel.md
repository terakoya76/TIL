# Cloudflare Tunnel


## Install cloudflared
- https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/private-net/

```bash
$ wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
$ sudo apt install -y ./cloudflared-linux-amd64.deb

$ cloudflared tunnel login

# certificate is stored on /home/hajime-terasawa/.cloudflared/cert.pem

$ cloudflared tunnel create grafana

$ cloudflared tunnel list

$ cat
tunnel: 8e343b13-a087-48ea-825f-9783931ff2a5
credentials-file: /root/.cloudflared/8e343b13-a087-48ea-825f-9783931ff2a5.json
warp-routing:
  enabled: true

$ cloudflared tunnel run grafana
```

## Automation
Once cloudflare tunnel is created, e.g. via terraform, you can run cloudflared with tonnel_token

```bash
cf_version="2022.10.3"
wget https://github.com/cloudflare/cloudflared/releases/download/$cf_version/cloudflared-linux-amd64.deb
apt install -y ./cloudflared-linux-amd64.deb
cloudflared service install ${cloudflared_tunnel_token}
```
