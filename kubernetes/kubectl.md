# kubectl

## run
entrypoint override (`command`)
```bash
$ image=quay.io/iovisor/kubectl-trace-bpftrace
$ k run -it --image=$image mycont --command -- /bin/bash
```
