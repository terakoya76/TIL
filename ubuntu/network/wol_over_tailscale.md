# WoL over Tailscale

ref: https://github.com/andygrundman/tailscale-wakeonlan?tab=readme-ov-file

```sh
# basic firewall
sudo ufw allow from 192.168.XX.0/24 to any port 22 proto tcp
sudo ufw enabled

# tailscale for wol proxy
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt-get update
sudo apt-get install -y tailscale
sudo tailscale up
tailscale ip -4
sudo ufw allow in on tailscale0

# docker for wol proxy
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
 "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
 $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose
usermod -aG docker ${USER}
sudo systemctl restart docker
sudo ufw allow in on docker0

# kernel parameter for wol proxy
sudo sysctl -w net.ipv4.conf.all.bc_forwarding=1
echo 'net.ipv4.conf.all.bc_forwarding=1' | sudo tee -a /etc/sysctl.d/90-docker-wakeonlan.conf
sudo sysctl -w net.ipv4.conf.docker0.bc_forwarding=1
echo 'net.ipv4.conf.docker0.bc_forwarding=1' | sudo tee -a /etc/sysctl.d/90-docker-wakeonlan.conf

# wol proxy
# https://github.com/andygrundman/tailscale-wakeonlan
TS_KEY=xxxxxxxxxxxxx
sudo docker run -d \
  --name tailscale-wakeonlan \
  -e TAILSCALE_HOSTNAME=wakeonlan \
  -e TAILSCALE_AUTHKEY=$TS_KEY \
  -e WOL_NETWORK=192.168.11.0/24 `#optional` \
  -v tailscale-wakeonlan-state:/var/lib/tailscale \
  --restart unless-stopped \
  --network bridge \
  ghcr.io/andygrundman/tailscale-wakeonlan:latest
```
