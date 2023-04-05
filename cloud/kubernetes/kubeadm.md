# Kubeadm

## Arch

### 物理構築
* Ref
  * https://developers.cyberagent.co.jp/blog/archives/14721/
  * https://kuromt.hatenablog.com/entry/2018/12/31/151410
* 素材
* usb to micro usb 0.3m * 3
  * https://www.amazon.co.jp/gp/product/B074VM7J5Z
* usbバッテリ
  * https://www.amazon.co.jp/gp/product/B00Z8Z7WEE
* 無線親機
  * https://www.amazon.co.jp/gp/product/B07R2CKQXC
* 積層ケース
  * https://www.amazon.co.jp/gp/product/B01F8AHNBA
* SDカード64gb * 3
  * https://www.amazon.co.jp/gp/product/B06XSWLYLF
* LANケーブル0.3m * 3
  * https://www.amazon.co.jp/gp/product/B00FZTNQ16
* LANケーブル0.15m
  * https://www.amazon.co.jp/gp/product/B00FZTNJQI
* スイッチングハブ5ポート
  * https://www.amazon.co.jp/gp/product/B00D5Q7V1M

### 論理構築
* Ref
  * https://qiita.com/shirot61/items/2321b70cd9c93f8f5cf0
  * https://kuromt.hatenablog.com/entry/2019/01/03/233347
* Raspberry Pi Imager
  * https://www.raspberrypi.com/software/

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

# allow ingress from tailscale
sudo ufw allow in on tailscale0
```

### IP Forwarding
```bash
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#forwarding-ipv4-and-letting-iptables-see-bridged-traffic
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
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

(Deprecated) docker cgroup driverをkubelet同様systemdに変更する（元はcgroupfs）
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
Kubernetes1.8からSwapが有効になっているとkubeletが起動しない
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

# 1.26 は互換性問題があるので避ける
# cf. https://stackoverflow.com/questions/75131916/failed-to-validate-kubelet-flags-the-container-runtime-endpoint-address-was-not
kversion="1.25.*"
apt update
apt install -y kubelet=$kversion kubeadm=$kversion kubectl=$kversion
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
CentOSとかで問題あるらしい
```bash
error execution phase preflight: [preflight] Some fatal errors occurred: [ERROR FileContent--proc-sys-net-ipv6-conf-default-forwarding]: /proc/sys/net/ipv6/conf/default/forwarding contents are not set to 1
```

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

### Create First `MasterNode`
```bash
# allow ingress from local network for etcd
# etcd を独立して構築すれば、回避できるかも
sudo ufw allow from 192.168.11.0/24 to any port 2379 proto tcp
sudo ufw allow from 192.168.11.0/24 to any port 2380 proto tcp

sudo su -
mkdir -p /etc/kubernetes/kubeadm

LOAD_BALANCER_DNS=k8s-control-plane.chozo.app
LOAD_BALANCER_PORT=6443
CONFIG_PATH=/etc/kubernetes/kubeadm/kubeadm-config.yaml

# cf. https://kubernetes.io/docs/reference/config-api/kubeadm-config.v1beta3/
cat <<EOF > ${CONFIG_PATH}
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: "$(tailscale ip -4)"
  bindPort: 6443
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: stable
# for multi-master
controlPlaneEndpoint: "${LOAD_BALANCER_DNS}:${LOAD_BALANCER_PORT}"
networking:
  # for calico, prevent from local network overlap
  podSubnet: 192.168.128.0/24
apiServer:
  certSANs:
    - $(tailscale ip -4)
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
  --token ugbkwq.1g48xce2lhbpmlcm \
  --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxx
```

When you have an expired cert like below
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

### Install CNI to have First `MasterNode` getting Ready
cf. https://kubernetes.io/ja/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network

When `ps for containerd`

```bash
sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock ps
```


#### cilium
cf. https://docs.cilium.io/en/latest/gettingstarted/k8s-install-default/


CLI
```bash
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/master/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

```bash
cilium install

sudo mount bpffs /sys/fs/bpf -t bpf
helm install cilium cilium/cilium --version 1.9.1 --namespace kube-system --set etcd.enabled=true --set etcd.managed=true
```

#### calico
cf. https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart
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

# https://docs.tigera.io/calico/3.25/reference/resources/ippool
cat > values.yaml <<EOF
installation:
  calicoNetwork:
    ipPools:
    - cidr: 192.168.128.0/24
      encapsulation: IPIPCrossSubnet
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

##### CASE1: calico-node がなぜか running にならない
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

##### CASE2: kubelet がエラーを吐いている
```bash
$ sudo journalctl -u kubelet -b
failed to validate kubelet flags: the container runtime endpoint address was not specified or empty, use --container-runtime-endpoint to set
```

cf. https://kubernetes.io/blog/2022/11/18/upcoming-changes-in-kubernetes-1-26/#cri-api-removal

> Kubernetes v1.26 は CRI をサポートしませんv1alpha2。その削除により、コンテナー ランタイムが CRI をサポートしていない場合、kubelet はノードを登録しませんv1。これは、containerd のマイナー バージョン 1.5 以前は Kubernetes 1.26 ではサポートされないことを意味します。containerd を使用する場合、そのノードを Kubernetes v1.26 にアップグレードする前に、 containerd バージョン 1.6.0 以降にアップグレードする必要があります。

containerd 1.6移行にするか、Kubernetes versionを1.25以前に変更する

##### CASE3: tailscale base の cluster で WorkerNode calico-node がなぜか running にならない
```bash
$ kubectl get po -A -o wide -w | grep calico
calico-apiserver   calico-apiserver-5f9d54c45c-7ml8g          1/1     Running    0              10h     192.168.128.5     raspberrypi-1    <none>           <none>
calico-apiserver   calico-apiserver-5f9d54c45c-d6w8l          1/1     Running    0              10h     192.168.128.6     raspberrypi-1    <none>           <none>
calico-system      calico-kube-controllers-6b7b9c649d-s8bsf   1/1     Running    0              10h     192.168.128.4     raspberrypi-1    <none>           <none>
calico-system      calico-node-8x7nx                          0/1     Init:1/2   5 (86s ago)    5m40s   100.yyy.yyy.yyy   indigo-4vcpu-1   <none>           <none>
calico-system      calico-node-h269g                          1/1     Running    23 (25m ago)   9h      100.xxx.xxx.xxx   raspberrypi-1    <none>           <none>
calico-system      calico-typha-65f9d89b5f-gcfnl              1/1     Running    0              10h     100.xxx.xxx.xxx   raspberrypi-1    <none>           <none>
calico-system      csi-node-driver-pl6kt                      2/2     Running    0              10h     192.168.128.2     raspberrypi-1    <none>           <none>

$ kubectl -n calico-system logs calico-node-8x7nx -c install-cni
time="2023-03-19T01:03:41Z" level=info msg="Running as a Kubernetes pod" source="install.go:145"
2023-03-19 01:03:42.990 [INFO][1] cni-installer/<nil> <nil>: File is already up to date, skipping file="/host/opt/cni/bin/bandwidth"
2023-03-19 01:03:42.990 [INFO][1] cni-installer/<nil> <nil>: Installed /host/opt/cni/bin/bandwidth
2023-03-19 01:03:43.056 [INFO][1] cni-installer/<nil> <nil>: File is already up to date, skipping file="/host/opt/cni/bin/calico"
2023-03-19 01:03:43.056 [INFO][1] cni-installer/<nil> <nil>: Installed /host/opt/cni/bin/calico
2023-03-19 01:03:43.111 [INFO][1] cni-installer/<nil> <nil>: File is already up to date, skipping file="/host/opt/cni/bin/calico-ipam"
2023-03-19 01:03:43.111 [INFO][1] cni-installer/<nil> <nil>: Installed /host/opt/cni/bin/calico-ipam
2023-03-19 01:03:43.114 [INFO][1] cni-installer/<nil> <nil>: File is already up to date, skipping file="/host/opt/cni/bin/flannel"
2023-03-19 01:03:43.114 [INFO][1] cni-installer/<nil> <nil>: Installed /host/opt/cni/bin/flannel
2023-03-19 01:03:43.117 [INFO][1] cni-installer/<nil> <nil>: File is already up to date, skipping file="/host/opt/cni/bin/host-local"
2023-03-19 01:03:43.117 [INFO][1] cni-installer/<nil> <nil>: Installed /host/opt/cni/bin/host-local
2023-03-19 01:03:43.183 [INFO][1] cni-installer/<nil> <nil>: File is already up to date, skipping file="/host/opt/cni/bin/install"
2023-03-19 01:03:43.184 [INFO][1] cni-installer/<nil> <nil>: Installed /host/opt/cni/bin/install
2023-03-19 01:03:43.188 [INFO][1] cni-installer/<nil> <nil>: File is already up to date, skipping file="/host/opt/cni/bin/loopback"
2023-03-19 01:03:43.188 [INFO][1] cni-installer/<nil> <nil>: Installed /host/opt/cni/bin/loopback
2023-03-19 01:03:43.191 [INFO][1] cni-installer/<nil> <nil>: File is already up to date, skipping file="/host/opt/cni/bin/portmap"
2023-03-19 01:03:43.192 [INFO][1] cni-installer/<nil> <nil>: Installed /host/opt/cni/bin/portmap
2023-03-19 01:03:43.195 [INFO][1] cni-installer/<nil> <nil>: File is already up to date, skipping file="/host/opt/cni/bin/tuning"
2023-03-19 01:03:43.195 [INFO][1] cni-installer/<nil> <nil>: Installed /host/opt/cni/bin/tuning
2023-03-19 01:03:43.195 [INFO][1] cni-installer/<nil> <nil>: Wrote Calico CNI binaries to /host/opt/cni/bin

2023-03-19 01:03:43.228 [INFO][1] cni-installer/<nil> <nil>: CNI plugin version: v3.25.0

2023-03-19 01:03:43.228 [INFO][1] cni-installer/<nil> <nil>: /host/secondary-bin-dir is not writeable, skipping
W0319 01:03:43.228178       1 client_config.go:617] Neither --kubeconfig nor --master was specified.  Using the inClusterConfig.  This might not work.
2023-03-19 01:04:13.258 [ERROR][1] cni-installer/<nil> <nil>: Unable to create token for CNI kubeconfig error=Post "https://10.96.0.1:443/api/v1/namespaces/calico-system/serviceaccounts/calico-node/token": dial tcp 10.96.0.1:443: i/o timeout
2023-03-19 01:04:13.258 [FATAL][1] cni-installer/<nil> <nil>: Unable to create token for CNI kubeconfig error=Post "https://10.96.0.1:443/api/v1/namespaces/calico-system/serviceaccounts/calico-node/token": dial tcp 10.96.0.1:443: i/o timeout

# 10.96.0.1:443 = default kubernetest service
$ kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   10h

# ok from MasterNode
$ curl -k https://10.96.0.1:443
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "forbidden: User \"system:anonymous\" cannot get path \"/\"",
  "reason": "Forbidden",
  "details": {},
  "code": 403
}

# ng from WorkerNode
$ curl -k https://10.96.0.1:443
curl: (28) Failed to connect to 10.96.0.1 port 443 after 129346 ms: Connection timed out

# WorkerNode 側でパケットキャプチャ
# MasterNode の private IP (API Server) に対してのリクエストが tailscale IP ではなく GIP 経由で問い合わせてパケロス
$ sudo tcpdump -i ens10 -n tcp
...
01:16:57.103299 IP 164.70.121.112.31434 > 192.168.11.16.6443: Flags [S], seq 2759418200, win 64240, options [mss 1460,sackOK,TS val 1302976355 ecr 0,nop,wscale 7], length 0
01:16:58.124608 IP 164.70.121.112.31434 > 192.168.11.16.6443: Flags [S], seq 2759418200, win 64240, options [mss 1460,sackOK,TS val 1302977376 ecr 0,nop,wscale 7], length 0
01:17:00.140610 IP 164.70.121.112.31434 > 192.168.11.16.6443: Flags [S], seq 2759418200, win 64240, options [mss 1460,sackOK,TS val 1302979392 ecr 0,nop,wscale 7], length 0
...

# kube-apiserver の advertiseAddress を tailscale IP に変える
# cf. https://kubernetes.io/docs/reference/config-api/kubeadm-config.v1beta3/
cat <<EOF >> ${CONFIG_PATH}
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: "$(tailscale ip -4)"
  bindPort: 6443
EOF
```

##### CASE4: calico-node が Running になるが、WorkerNode が NotReady

```bash
$ kubectl get no
NAME             STATUS     ROLES           AGE   VERSION
indigo-4vcpu-1   NotReady   <none>          15m   v1.25.8
raspberrypi-1    Ready      control-plane   19m   v1.25.8

$ kubectl get po -A -o wide
NAMESPACE          NAME                                       READY   STATUS    RESTARTS      AGE     IP                NODE             NOMINATED NODE   READINESS GATES
calico-apiserver   calico-apiserver-79f6c97f4b-vqwf4          1/1     Running   0             16m     192.168.128.6     raspberrypi-1    <none>           <none>
calico-apiserver   calico-apiserver-79f6c97f4b-xmrpg          1/1     Running   0             16m     192.168.128.5     raspberrypi-1    <none>           <none>
calico-system      calico-kube-controllers-5f9dc85578-lf7dw   1/1     Running   0             17m     192.168.128.1     raspberrypi-1    <none>           <none>
calico-system      calico-node-brvpd                          1/1     Running   2 (16s ago)   17m     100.xxx.xxx.xxx   raspberrypi-1    <none>           <none>
calico-system      calico-node-dfs6l                          1/1     Running   0             4m59s   100.yyy.yyy.yyy   indigo-4vcpu-1   <none>           <none>
calico-system      calico-typha-587866d56f-b8qhb              1/1     Running   0             17m     100.xxx.xxx.xxx   raspberrypi-1    <none>           <none>
calico-system      csi-node-driver-2c22c                      2/2     Running   0             17m     192.168.128.2     raspberrypi-1    <none>           <none>
kube-system        coredns-565d847f94-8p5dh                   1/1     Running   0             19m     192.168.128.3     raspberrypi-1    <none>           <none>
kube-system        coredns-565d847f94-k2p2m                   1/1     Running   0             19m     192.168.128.4     raspberrypi-1    <none>           <none>
kube-system        etcd-raspberrypi-1                         1/1     Running   1             19m     100.xxx.xxx.xxx   raspberrypi-1    <none>           <none>
kube-system        kube-apiserver-raspberrypi-1               1/1     Running   1             19m     100.xxx.xxx.xxx   raspberrypi-1    <none>           <none>
kube-system        kube-controller-manager-raspberrypi-1      1/1     Running   4             19m     100.xxx.xxx.xxx   raspberrypi-1    <none>           <none>
kube-system        kube-proxy-5rzqw                           1/1     Running   0             15m     100.yyy.yyy.yyy   indigo-4vcpu-1   <none>           <none>
kube-system        kube-proxy-d2hm2                           1/1     Running   0             19m     100.xxx.xxx.xxx   raspberrypi-1    <none>           <none>
kube-system        kube-scheduler-raspberrypi-1               1/1     Running   14            19m     100.xxx.xxx.xxx   raspberrypi-1    <none>           <none>
tigera-operator    tigera-operator-64db64cb98-vk4b8           1/1     Running   0             18m     100.xxx.xxx.xxx   raspberrypi-1    <none>           <none>

# MTU がおかしい？
$ kubectl -n calico-system logs calico-node-dfs6l
...
2023-03-22 03:05:15.852 [INFO][87] felix/vxlan_mgr.go 685: VXLAN device MTU needs to be updated device="vxlan.calico" ipVersion=0x4 new=1450 old=1230
2023-03-22 03:05:15.852 [WARNING][87] felix/vxlan_mgr.go 687: Failed to set vxlan tunnel device MTU error=invalid argument ipVersion=0x4
2023-03-22 03:05:25.854 [INFO][87] felix/vxlan_mgr.go 685: VXLAN device MTU needs to be updated device="vxlan.calico" ipVersion=0x4 new=1450 old=1230
2023-03-22 03:05:25.854 [WARNING][87] felix/vxlan_mgr.go 687: Failed to set vxlan tunnel device MTU error=invalid argument ipVersion=0x4

$ ip a
...
7: vxlan.calico: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1230 qdisc noqueue state UNKNOWN group default
    link/ether 66:d9:d8:d0:eb:c7 brd ff:ff:ff:ff:ff:ff
    inet 192.168.128.128/32 scope global vxlan.calico
       valid_lft forever preferred_lft forever

# この host では VXLAN を使うための MTU を指定できない。
$ sudo ip link set dev vxlan.calico mtu 1450
RTNETLINK answers: Invalid argument

# VXLAN -> IPIP へ変更
$ vim values.yaml
---
installation:
  calicoNetwork:
    ipPools:
    - cidr: 192.168.128.0/24
      encapsulation: VXLANCrossSubnet -> IPIPCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
    nodeAddressAutodetectionV4:
      firstFound: false
      cidrs:
        - "100.0.0.0/8"
---
```

Install calicoctl
```bash
wget https://github.com/projectcalico/calicoctl/releases/download/v3.20.6/calicoctl-linux-amd64
mv calicoctl-linux-amd64 calicoctl
chmod +x calicoctl
```

#### flannel
```bash
helm install flannel --set podCidr="10.244.0.0/16" https://github.com/flannel-io/flannel/releases/latest/download/flannel.tgz
```

## Cleanup
for `WorkerNode`
```bash
kubectl drain node-0-2 --delete-local-data --force --ignore-daemonsets
kubectl delete node node-0-2

sudo su -
kubeadm reset
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
rm -r /etc/cni/net.d
```

for `MasterNode`
```bash
sudo su -
kubeadm reset
rm -r /etc/cni/net.d
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
exit
rm ~/.kube/config
```
