# Kubeadm

## Arch

### 物理構築
* Ref
  * https://developers.cyberagent.co.jp/blog/archives/14721/
  * https://kuromt.hatenablog.com/entry/2018/12/31/151410
* 素材
* usb to micro usb 0.3m * 3
  * https://www.amazon.co.jp/gp/product/B074VM7J5Z
* usb バッテリ
  * https://www.amazon.co.jp/gp/product/B00Z8Z7WEE
* 無線親機
  * https://www.amazon.co.jp/gp/product/B07R2CKQXC
* 積層ケース
  * https://www.amazon.co.jp/gp/product/B01F8AHNBA
* SD カード 64gb * 3
  * https://www.amazon.co.jp/gp/product/B06XSWLYLF
* LAN ケーブル 0.3m * 3
  * https://www.amazon.co.jp/gp/product/B00FZTNQ16
* LAN ケーブル 0.15m
  * https://www.amazon.co.jp/gp/product/B00FZTNJQI
* スイッチングハブ 5ポート
  * https://www.amazon.co.jp/gp/product/B00D5Q7V1M

### 論理構築
* Ref
  * https://qiita.com/shirot61/items/2321b70cd9c93f8f5cf0
  * https://kuromt.hatenablog.com/entry/2019/01/03/233347
* Raspberry Pi Imager
  * https://www.raspberrypi.org/downloads/

## SSH
cf. https://qiita.com/xshell/items/af4e2ef8d804cd29e38e

```bash
sudo arp-scan -l --interface en0
ssh ubuntu@192.168.13.3
sudo apt update
sudo apt upgrade
```

## Preparation

### resolverを google dns に向ける
```bash
sudo vi /etc/systemd/resolved.conf
DNS=8.8.8.8
FallbackDNS=8.8.4.4

sudo systemctl restart systemd-resolved.service
nslookup www.google.com
```

### (Optional) server は固定 ip に
```bash
ip a
(snip)
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    (snip)
    inet 192.168.13.4/24 brd 192.168.13.255 scope global dynamic eth0
  	(snip)

sudo vi /etc/systemd/network/01-static.network
[Match]
Name=eth0

[Network]
Address=192.168.13.4/24
Gateway=192.168.13.1
DNS=192.168.13.1

sudo systemctl restart systemd-networkd.service
```

### setup tailscale for inter-node communication
```bash
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

sudo apt update
sudo apt install -y tailscale
sudo tailscale up
```

### Setup CRI
```bash
# setup apt repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
   "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# install
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
usermod -aG docker ${USER}
sudo systemctl restart docker

# SystemdCgroup enable:
# cf. https://kubernetes.io/docs/setup/production-environment/container-runtimes/#systemd-cgroup-driver
# for. [ERROR CRI]: container runtime is not running: output: time="2023-02-26T14:02:55+09:00" level=fatal msg="validate service connection: CRI v1 runtime API is not implemented for endpoint \"unix:///var/run/containerd/containerd.sock\": rpc error: code = Unimplemented desc = unknown service runtime.v1.RuntimeService"
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i "s/SystemdCgroup = false/SystemdCgroup = true/g" /etc/containerd/config.toml
sudo systemctl restart containerd
```

(Deprecated) docker cgroup driver を kubelet 同様 systemd に変更する（元は cgroupfs）
* Ref: https://kubernetes.io/docs/setup/production-environment/container-runtimes/

```bash
sudo su -
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d
systemctl daemon-reload
systemctl restart docker
systemctl enable docker.service

docker info | grep -i cgroup
Cgroup Driver: systemd
```

### Disable Swap
Kubernetes1.8 から Swap が有効になっていると kubelet が起動しない
```bash
free -h
swapon -s
```


### Install kube-xxx
```bash
sudo su -

apt update && apt install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
```

## kubeadm
### Adjust Node IP
```bash
# change hostname
sudo sed -i "s/^preserve_hostname: false/preserve_hostname: true/g" /etc/cloud/cloud.cfg
sudo hostnamectl set-hostname raspberrypi-1

# use private ip as node
echo "KUBELET_EXTRA_ARGS=--node-ip=$(tailscale ip -4)" | sudo tee /etc/default/kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

### Setup Gateway
CentOS とかで問題あるらしい
* `error execution phase preflight: [preflight] Some fatal errors occurred: [ERROR FileContent--proc-sys-net-ipv6-conf-default-forwarding]: /proc/sys/net/ipv6/conf/default/forwarding contents are not set to 1`

```bash
echo 1 > /proc/sys/net/ipv6/conf/default/forwarding

sudo su -
vi /etc/sysctl.conf
`net.ipv6.conf.all.forwarding ` comment out
```

### Host Network と Pod Network の CIDR を決定
* host `100.0.0.0/8`
  * tailscale
* pod `192.168.0.0/16`
  * for calico
* pod `10.217.0.0/16`
  * for cilium
* pod `10.244.0.0/16`
  * for flannel

### Create First Master Node
```bash
# allow ingress from tailscale
sudo ufw allow in on tailscale0

# allow ingress from local network for etcd
# etcd を独立して構築すれば、回避できるかも
sudo ufw allow from 192.168.11.0/24 to any port 2379 proto tcp
sudo ufw allow from 192.168.11.0/24 to any port 2380 proto tcp

sudo su -
mkdir -p /etc/kubernetes/kubeadm

LOAD_BALANCER_DNS=k8s-control-plane.chozo.app
LOAD_BALANCER_PORT=6443
CONFIG_PATH=/etc/kubernetes/kubeadm/kubeadm-config.yaml

cat <<EOF > ${CONFIG_PATH}
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: stable
# for multi-master
controlPlaneEndpoint: "${LOAD_BALANCER_DNS}:${LOAD_BALANCER_PORT}"
networking:
  # for calico, prevent from local network overlap
  podSubnet: 192.168.128.0/24
  # apiServer:
  #   extraArgs:
  #     advertise-address: $(tailscale ip -4)
EOF

kubeadm init --config=${CONFIG_PATH} --upload-certs
exit

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Join Other Node
```bash
# check join command
sudo kubeadm token create --print-join-command

# on other master node
sudo kubeadm join ${LOAD_BALANCER_DNS}:${LOAD_BALANCER_PORT} \
  --config=${CONFIG_PATH} \
  --control-plane \
  --token ugbkwq.1g48xce2lhbpmlcm \
  --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxx

# on other worker node
sudo kubeadm join ${LOAD_BALANCER_DNS}:${LOAD_BALANCER_PORT} \
  --control-plane \
  --token ugbkwq.1g48xce2lhbpmlcm \
  --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxx
  # --apiserver-advertise-address=$(tailscale ip -4)
```

When your cert is expired like below
```
One or more conditions for hosting a new control plane instance is not satisfied.

[failure loading certificate for CA: couldn't load the certificate file /etc/kubernetes/pki/ca.crt: open /etc/kubernetes/pki/ca.crt: no such file or directory, failure loading key for service account: couldn't load the private key file /etc/kubernetes/pki/sa.key: open /etc/kubernetes/pki/sa.key: no such file or directory, failure loading certificate for front-proxy CA: couldn't load the certificate file /etc/kubernetes/pki/front-proxy-ca.crt: open /etc/kubernetes/pki/front-proxy-ca.crt: no such file or directory, failure loading certificate for etcd CA: couldn't load the certificate file /etc/kubernetes/pki/etcd/ca.crt: open /etc/kubernetes/pki/etcd/ca.crt: no such file or directory]
```

You need to re-upload certs, and use it
```bash
# generate new cert
sudo kubeadm init phase upload-certs --upload-certs

# then use it
sudo kubeadm join ${LOAD_BALANCER_DNS}:${LOAD_BALANCER_PORT} \
  --control-plane \
  --token ugbkwq.1g48xce2lhbpmlcm \
  --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxx \
  # --apiserver-advertise-address=$(tailscale ip -4) \
  --certificate-key yyyyyyyyyyyyyyyy
```

### Install CNI to have First Master Node getting Ready
cf. https://kubernetes.io/ja/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network

#### cilium
cf. https://docs.cilium.io/en/v1.8/gettingstarted/k8s-install-default/

```bash
kubectl create -f https://raw.githubusercontent.com/cilium/cilium/v1.8/install/kubernetes/quick-install.yaml

sudo mount bpffs /sys/fs/bpf -t bpf
helm install cilium cilium/cilium --version 1.9.1 --namespace kube-system --set etcd.enabled=true --set etcd.managed=true
```

#### calico
cf. https://docs.tigera.io/calico/3.25/getting-started/kubernetes/quickstart
```bash
# allow ingress from Calico node via default svc
sudo ufw allow from 192.168.11.0/24 to any port 6443 proto tcp

# install helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt install -y apt-transport-https
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt update
sudo apt install -y helm

helm repo add projectcalico https://docs.tigera.io/calico/charts
cat > values.yaml <<EOF
installation:
  calicoNetwork:
    bgp: Disabled
    ipPools:
    - cidr: 192.168.128.0/24
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
    nodeAddressAutodetectionV4:
      firstFound: false
      cidrs:
        - "100.0.0.0/8"
EOF
kubectl create ns tigera-operator
helm install calico projectcalico/tigera-operator -f values.yaml --namespace tigera-operator
```

calico-node が何故か running にならない
```bash
ubuntu@node-0-0:~$ kubectl get po -A
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-59877c7fb4-7vc54   1/1     Running   0          5h7m
kube-system   calico-node-6xbmb                          0/1     Running   4          9m34s
kube-system   calico-node-z72qz                          0/1     Running   79         5h7m
kube-system   coredns-66bff467f8-g24zk                   1/1     Running   0          5h9m
kube-system   coredns-66bff467f8-qxc82                   1/1     Running   0          5h9m
kube-system   etcd-node-0-0                              1/1     Running   0          5h9m
kube-system   kube-apiserver-node-0-0                    1/1     Running   0          5h9m
kube-system   kube-controller-manager-node-0-0           1/1     Running   0          5h9m
kube-system   kube-proxy-bcfx6                           1/1     Running   0          5h9m
kube-system   kube-proxy-w4mn7                           1/1     Running   0          9m34s
kube-system   kube-scheduler-node-0-0                    1/1     Running   1          5h9m

kubectl describe po calico-node-6xbmb -n kube-system
(snip)
Warning  Unhealthy  14m (x5 over 14m)      kubelet, node-0-0  Liveness probe failed: calico/node is not ready: Felix is not live: Get http://localhost:9099/liveness: dial tcp 127.0.0.1:9099: connect: connection refused
  Warning  Unhealthy  11m (x17 over 14m)     kubelet, node-0-0  Readiness probe failed: calico/node is not ready: felix is not ready: Get http://localhost:9099/readiness: dial tcp 127.0.0.1:9099: connect: connection refused
  Warning  BackOff    6m22s (x3 over 6m37s)  kubelet, node-0-0  Back-off restarting failed container
  Normal   Pulled     84s (x7 over 13m)      kubelet, node-0-0  Container image "calico/node:v3.11.3" already present on machine

kubectl logs calico-node-6xbmb -n kube-system
(snip)
2020-08-29 14:25:54.221 [FATAL][558] int_dataplane.go 1035: Kernel's RPF check is set to 'loose'.  This would allow endpoints to spoof their IP address.  Calico requires net.ipv4.conf.all.rp_filter to be set to 0 or 1. If you require loose RPF and you are not concerned about spoofing, this check can be disabled by setting the IgnoreLooseRPF configuration parameter to 'true'.

# 逆方向パス転送を厳格化する
sudo sysctl -w net.ipv4.conf.all.rp_filter=1 （sudo vi /etc/sysctl.conf で永続化）
```

#### flannel
```bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

## Cleanup
for worker node
```bash
kubectl drain node-0-2 --delete-local-data --force --ignore-daemonsets
kubectl delete node node-0-2

sudo su -
kubeadm reset
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
rm -r /etc/cni/net.d
```

for master node
```bash
sudo su -
kubeadm reset
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
rm -r /etc/cni/net.d
exit
rm ~/.kube/config
```
