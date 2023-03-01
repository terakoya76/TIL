# Lambda Custom Runtime

## bash Runtime
Ref: https://docs.aws.amazon.com/lambda/latest/dg/runtimes-walkthrough.html

Dockerfile
```Dockerfile
FROM public.ecr.aws/lambda/provided:al2

RUN yum install -y \
        curl \
        jq \
        mariadb-client \
        python3 \
        py-pip \
    && pip3 install awscli

COPY bootstrap $LAMBDA_RUNTIME_DIR/bootstrap
COPY scripts $LAMBDA_TASK_ROOT/

# need to override real handler function
CMD ["function.handler"]
```

bootstrap
```bash
#!/bin/sh

set -euo pipefail

# Initialization - load function handler
source $LAMBDA_TASK_ROOT/"$(echo $_HANDLER | cut -d. -f1).sh"

# Processing
while true
do
  HEADERS="$(mktemp)"

  # Get an event. The HTTP request will block until one is received
  EVENT_DATA=$(curl -sS -LD "$HEADERS" -X GET "http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/next")

  # Extract request ID by scraping response headers received above
  REQUEST_ID=$(grep -Fi Lambda-Runtime-Aws-Request-Id "$HEADERS" | tr -d '[:space:]' | cut -d: -f2)

  # Run the handler function from the script
  RESPONSE=$($(echo "$_HANDLER" | cut -d. -f2) "$EVENT_DATA")

  # Send the response
  curl -X POST "http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/$REQUEST_ID/response"  -d "$RESPONSE"
done
```

handler
```function.sh
function handler () {
  EVENT=$1
  echo "$EVENT" 1>&2;
  RESPONSE="Echoing request: '$EVENT'"

  echo $RESPONSE
}
```

## Runtime Interface Emulator

```Dockerfile
FROM alpine:3.13.0

RUN apk add curl \
    && curl -Lo ~/.aws-lambda-rie/aws-lambda-rie https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie \
    && ./aws-lambda-rie /aws-lambda-rie

$ chmod +x aws-lambda-rie
ENV LAMBDA_RUNTIME_DIR=/var/runtime \
   LAMBDA_TASK_ROOT=/var/task

COPY bootstrap /$LAMBDA_RUNTIME_DIR/bootstrap
COPY main.sh $LAMBDA_TASK_ROOT/

WORKDIR $LAMBDA_TASK_ROOT

ENTRYPOINT ["/var/runtime/bootstrap"]
CMD ["function.handler"]
```

```bash
$ docker run --rm -p 9000:8080 \
    -v $(pwd)/aws-lambda-rie:/aws-lambda-rie \
    --entrypoint="/aws-lambda-rie" \
    lambda_image
$ curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"key": "value"}'
```
