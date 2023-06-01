# match doks-debug version with DOKS worker node image version for kernel
# tooling compatibility reasons
FROM debian:12-slim

# Specify the version of crictl to install
ARG CRICTL_VERSION="v1.31.1"

LABEL org.opencontainers.image.source=https://github.com/nosportugal/debug-pod
LABEL org.opencontainers.image.description="A debian image with some debugging tools installed."

WORKDIR /root

# use same dpkg path-exclude settings that come by default with ubuntu:focal
# image that we previously used
RUN echo 'path-exclude=/usr/share/locale/*/LC_MESSAGES/*.mo' >> /etc/dpkg/dpkg.cfg.d/excludes
RUN echo 'path-exclude=/usr/share/doc/*' >> /etc/dpkg/dpkg.cfg.d/excludes
RUN echo 'path-include=/usr/share/doc/*/copyright' >> /etc/dpkg/dpkg.cfg.d/excludes
RUN echo 'path-include=/usr/share/doc/*/changelog.Debian.*' >> /etc/dpkg/dpkg.cfg.d/excludes

RUN apt-get update && \
    apt-get install -y apt-transport-https \
                       ca-certificates \
                       software-properties-common \
                       httping \
                       man \
                       man-db \
                       vim \
                       screen \
                       curl \
                       gnupg \
                       atop \
                       htop \
                       dstat \
                       jq \
                       dnsutils \
                       tcpdump \
                       traceroute \
                       iputils-ping \
                       iptables \
                       net-tools \
                       ncat \
                       iproute2 \
                       strace \
                       telnet \
                       openssl \
                       psmisc \
                       dsniff \
                       mtr-tiny \
                       conntrack \
                       llvm-13 llvm-13-tools \
                       wget \
                       bpftool \
                       nmap

# Install crictl
RUN wget https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz && \
    tar zxvf crictl-${CRICTL_VERSION}-linux-amd64.tar.gz -C /usr/local/bin && \
    rm -f crictl-${CRICTL_VERSION}-linux-amd64.tar.gz

# Specify the default image endpoint for crictl
RUN echo 'runtime-endpoint: unix:///run/containerd/containerd.sock' >> /etc/crictl.yaml
RUN echo 'image-endpoint: unix:///run/containerd/containerd.sock' >> /etc/crictl.yaml
RUN echo 'timeout: 2' >> /etc/crictl.yaml

# for httpie
RUN curl -SsL https://packages.httpie.io/deb/KEY.gpg | gpg --dearmor -o /usr/share/keyrings/httpie.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/httpie.gpg] https://packages.httpie.io/deb ./" > /etc/apt/sources.list.d/httpie.list && \
    apt-get update && \
    apt-get install -y httpie

ENTRYPOINT [ "/bin/bash" ]
