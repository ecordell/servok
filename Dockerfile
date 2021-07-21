FROM golang:1.16-alpine3.13 AS build

ARG GRPC_HEALTH_PROBE_VERSION=0.3.6
RUN apk add curl
RUN curl -Lo /go/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/v${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64
RUN chmod +x /go/bin/grpc_health_probe

WORKDIR /go/src/servok
RUN go env -w GOPRIVATE=github.com/REDACTED/code

COPY ./go.mod ./go.sum .
RUN go mod download

COPY ./ /go/src/servok
RUN go install -v ./...

FROM alpine:3.14.0
COPY --from=build /go/bin/* /usr/local/bin/
CMD ["servok"]
