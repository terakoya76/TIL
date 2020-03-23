# Startup Script
exec by sudo
```bash
set -ue

user=hoge
ssh_port=22

cloudflared_version=2023.2.1
cloudflared_tunnel_token=xxxxx
cloudflare_access_ca_cert_public_key=xxxxx

#-------------------------------
# user
#-------------------------------
adduser --disabled-password --gecos "" --force-badname ${user}
usermod -aG sudo ${user}
echo "${user} ALL=(ALL) NOPASSWD: ALL" | EDITOR="tee -a" visudo

#-------------------------------
# fw
#-------------------------------
ufw default deny
ufw limit ${ssh_port}
echo "y" | ufw enable

#-------------------------------
# cloudflare
#-------------------------------
cloudflare_access_ca_cert_public_key_file="/etc/ssh/ca.pub"

echo "${cloudflare_access_ca_cert_public_key}" > ${cloudflare_access_ca_cert_public_key_file}
echo "TrustedUserCAKeys ${cloudflare_access_ca_cert_public_key_file}" >> /etc/ssh/sshd_config
systemctl restart sshd

if [ $(uname -m) = "x86_64" ]; then
    wget https://github.com/cloudflare/cloudflared/releases/download/${cloudflared_version}/cloudflared-linux-amd64.deb
    apt install -y ./cloudflared-linux-amd64.deb
    cloudflared service install ${cloudflared_tunnel_token}
elif [ $(uname -m) = "aarch64" ]; then
    wget https://github.com/cloudflare/cloudflared/releases/download/${cloudflared_version}/cloudflared-linux-arm64.deb
    apt install -y ./cloudflared-linux-arm64.deb
    cloudflared service install ${cloudflared_tunnel_token}
fi

#-------------------------------
# or tailscale
#-------------------------------
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list

apt update
apt install -y tailscale
tailscale up

#-------------------------------
# docker
#-------------------------------
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
usermod -aG docker ${user}

docker buildx ls
apt install -y qemu-user-static
docker buildx ls
```
