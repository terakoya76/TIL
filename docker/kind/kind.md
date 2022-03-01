# kind
Ref: https://kind.sigs.k8s.io/docs/user/quick-start/

## quick install
```bash
$ GO111MODULE="on" go get sigs.k8s.io/kind@v0.9.0

# default cluster name is `kind`
$ kind create cluster

# for printing debug log
$ kind create cluster --loglevel debug
```

## install from the configuration
config
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
```

designate config
```bash
$ kind create cluster --config kind.yaml
```

## Mapping FS
```bash
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
kubeadmConfigPatches:
- |
  apiVersion: kubeadm.k8s.io/v1beta2
  kind: ClusterConfiguration
  metadata:
    name: config
  networking:
    serviceSubnet: 10.0.0.0/16
  # control-plane 上で動く api-server に control-plane の FS を mount
  apiServer:
    extraVolumes:
    - name: "test"
      hostPath: /test
      mountPath: /test
nodes:
- role: control-plane
  # api-server が mount したい path を control-plane へ mount
  extraMounts:
  - containerPath: /test
    hostPath: /mnt/test
```

## Mapping Ports
```bash
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    listenAddress: "0.0.0.0" # Optional, defaults to "0.0.0.0"
    protocol: udp # Optional, defaults to tcp
```

## Enable Feature Gate
```bash
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
featureGates:
  "CSIMigration": true
nodes:
- role: control-plane
```

## Self Hosted Image
```bash
# run local private registry
$ docker run -d -p 5000:5000 registry

# push custom node image
$ docker build -t localhost:5000/node:v1.19.1 -f kubernetes/kind/Dockerfile .
$ docker push localhost:5000/node:v1.19.1

$ kind create cluster --config=kubernetes/kind/self_hosted_image.yaml
```

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
  image: localhost:5000/node:v1.19.1
```
