## Home k8s

### 物理構築
Ref
* https://developers.cyberagent.co.jp/blog/archives/14721/
* https://kuromt.hatenablog.com/entry/2018/12/31/151410

usb to micro usb 0.3m * 3
* https://www.amazon.co.jp/gp/product/B074VM7J5Z

usb バッテリ
* https://www.amazon.co.jp/gp/product/B00Z8Z7WEE

無線親機
* https://www.amazon.co.jp/gp/product/B07R2CKQXC

積層ケース
* https://www.amazon.co.jp/gp/product/B01F8AHNBA

SD カード 64gb * 3
* https://www.amazon.co.jp/gp/product/B06XSWLYLF

LAN ケーブル 0.3m * 3
* https://www.amazon.co.jp/gp/product/B00FZTNQ16

LAN ケーブル 0.15m
* https://www.amazon.co.jp/gp/product/B00FZTNJQI

スイッチングハブ 5ポート
* https://www.amazon.co.jp/gp/product/B00D5Q7V1M

### 論理構築
Ref
* https://qiita.com/shirot61/items/2321b70cd9c93f8f5cf0
* https://kuromt.hatenablog.com/entry/2019/01/03/233347

Raspberry Pi Imager
* https://www.raspberrypi.org/downloads/

SDcard への OS の書き込みに便利
* 今回は `ubuntu 20.04.1 LTS` を選択

疎通確認
```bash
$ brew install arp-scan
$ ifconfig
$ sudo arp-scan -l --interface en0
$ ssh ubuntu@192.168.13.3
$ sudo apt update
$ sudo apt upgrade
```

公開鍵認証
```bash
$ scp ~/.ssh/id_rsa.pub ubuntu@192.168.13.3:/home/ubuntu/.ssh/authorized_keys
$ ssh ubuntu@192.168.13.3
$ sudo vi /etc/ssh/sshd_config
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no

$ service sshd restart
```

resolver を google dns に向ける
```bash
$ sudo vi /etc/systemd/resolved.conf
DNS=8.8.8.8
FallbackDNS=8.8.4.4

$ sudo systemctl restart systemd-resolved.service
$ nslookup www.google.com
```

server を固定 IP に
```bash
$ ip a
 (snip)
 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
     (snip)
     inet 192.168.13.4/24 brd 192.168.13.255 scope global dynamic eth0
   	(snip)

$ sudo vi /etc/systemd/network/01-static.network
[Match]
Name=eth0

[Network]
Address=192.168.13.4/24
Gateway=192.168.13.1
DNS=192.168.13.1

$ sudo systemctl restart systemd-networkd.service
```

server 間で名前解決できるようにする
```bash
$ cat >> /etc/hosts <<EOF
# 自 hostname を指定
127.0.0.1 node-0-0

192.168.13.2 node-0-0
192.168.13.3 node-0-1
192.168.13.4 node-0-2
EOF

$ ssh node-0-0 sudo shutdown -r now
```

docker install
```bash
$ apt show docker.io
$ sudo apt-get -y install docker.io
$ docker --version
$ sudo gpasswd -a ubuntu docker
$ sudo systemctl restart docker

# exit and re-login
$ docker container run -t --rm hello-world
```

CRI setup
* https://kubernetes.io/docs/setup/production-environment/container-runtimes/
```bash
$ sudo su -
# docker cgroup driver を kubelet 同様 systemd に変更する（元は cgroupfs）
$ cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

$ mkdir -p /etc/systemd/system/docker.service.d
$ systemctl daemon-reload
$ systemctl restart docker
$ systemctl enable docker.service
$ docker info | grep -i cgroup
Cgroup Driver: systemd
```

kube tools install
```bash
$ sudo su -
$ apt update && apt install -y apt-transport-https curl
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
$ cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

$ kversion="1.19.*"
$ apt update
$ apt install -y kubelet=$kversion kubeadm=$kversion kubectl=$kversion
$ apt-mark hold kubelet kubeadm kubectl
$ dpkg -l |grep kube
```

create cluster
```bash
# pod network `192.168.0.0/16` for calico
# pod network `10.217.0.0/16` for cilium
# pod network `10.244.0.0/16` for flannel
$ sudo kubeadm init --pod-network-cidr=10.217.0.0/16
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### CNI(Cilium)
mount bpffs
```bash
$ mount bpffs /sys/fs/bpf -t bpf
```

use kubectl to install cilium
```bash
$ kubectl create -f https://raw.githubusercontent.com/cilium/cilium/v1.9/install/kubernetes/quick-install.yaml
```

use aarch64 adapted images instead of non-dev amd64 images
* https://hub.docker.com/r/cilium/cilium-dev
* https://hub.docker.com/r/cilium/operator-dev

v1.9.x image require to be provided `--disable-envoy-version-check` for aarch64
* https://github.com/cilium/cilium/issues/14117#issuecomment-739104709

### 論理削除
Ref: https://kubernetes.io/ja/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#tear-down

# for worker node
```bash
$ kubectl drain node-0-1 --delete-local-data --force --ignore-daemonsets
$ kubectl delete node node-0-1
$ kubectl drain node-0-2 --delete-local-data --force --ignore-daemonsets
$ kubectl delete node node-0-2

$ sudo su -
$ kubeadm reset
$ iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
$ rm -r /etc/cni/net.d
```

# for master node
```bash
$ sudo su -
$ kubeadm reset
$ iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
$ rm -r /etc/cni/net.d
$ exit
$ rm ~/.kube/config
```
