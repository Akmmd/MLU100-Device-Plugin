FROM ubuntu:16.04 as build

RUN  sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN  apt-get clean

RUN apt-get update && apt-get install -y --no-install-recommends \
        g++ \
        ca-certificates \
        wget \
        apt-utils && \
rm -rf /var/lib/apt/lists/*



RUN wget -nv -O - https://studygolang.com/dl/golang/go1.12.1.linux-amd64.tar.gz \
    | tar -C /usr/local -xz

ENV GOPATH /go

ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH


ARG DIR=/go/src/github.com/intel/intel-device-plugins-for-kubernetes
WORKDIR $DIR
COPY . .
RUN cd cmd/gpu_plugin; go install
RUN chmod a+x /go/bin/gpu_plugin

FROM debian:stretch-slim

COPY --from=build /go/bin/gpu_plugin /usr/bin/intel_gpu_device_plugin
CMD ["/usr/bin/intel_gpu_device_plugin"]
#CMD ["/go/bin/gpu_plugin"]