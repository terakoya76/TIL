FROM kindest/node:v1.19.1

# do something
RUN apt update && apt install -y bpfcc-tools
# RUN apt update && apt install -y bpftrace

# https://github.com/kubernetes-sigs/kind/blob/8ea030becbb6e0ef9012b0631e892f7d15281962/pkg/build/nodeimage/build_impl.go#L129
ENTRYPOINT [ "/usr/local/bin/entrypoint", "/sbin/init" ]
