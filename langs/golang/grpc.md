# gRPC

## evans
enable server reflection
cf. https://github.com/grpc/grpc/blob/master/doc/server-reflection.md
```go
import (
    "google.golang.org/grpc/reflection"
)

func main() {
    s := grpc.NewServer()
    pb.RegisterGreeterServer(s, &server{})

    // Register reflection service on gRPC server.
    reflection.Register(s)
}
```

then evans
cf. https://github.com/ktr0731/evans
```bash
$ evans -r repl -p xxxx

> show package

> package api

> show service

> service example

> call hoge
```
