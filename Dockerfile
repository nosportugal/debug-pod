FROM debian:13 AS builder

# Build curl with HTTP/3 support using ngtcp2 (non-experimental) backend.
# Debian 13 ships OpenSSL 3.5 which has native QUIC API support for ngtcp2.
# https://github.com/curl/curl/blob/master/docs/HTTP3.md#ngtcp2-version

WORKDIR /opt

ARG CURL_VERSION=curl-8_18_0
ARG NGTCP2_VERSION=v1.20.0
ARG NGHTTP3_VERSION=v1.15.0

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get full-upgrade --auto-remove --purge -y && \
    apt-get install -y build-essential git autoconf libtool pkg-config \
        libssl-dev libnghttp2-dev zlib1g-dev libpsl-dev;

# Build nghttp3
RUN git clone -b $NGHTTP3_VERSION https://github.com/ngtcp2/nghttp3 && \
    cd nghttp3 && \
    git submodule update --init && \
    autoreconf -fi && \
    ./configure --prefix=/usr/local --enable-lib-only && \
    make --jobs=$(nproc) && \
    make install

# Build ngtcp2 (with system OpenSSL 3.5+)
RUN git clone -b $NGTCP2_VERSION https://github.com/ngtcp2/ngtcp2 && \
    cd ngtcp2 && \
    autoreconf -fi && \
    ./configure PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
        --prefix=/usr/local --enable-lib-only --with-openssl && \
    make --jobs=$(nproc) && \
    make install

# Build curl with HTTP/3 (ngtcp2 + nghttp3) + HTTP/2 (nghttp2) + TLS (OpenSSL)
RUN git clone https://github.com/curl/curl && \
    cd curl && \
    git checkout $CURL_VERSION && \
    autoreconf -fi && \
    ./configure PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
        --with-openssl --with-nghttp3 --with-ngtcp2 --with-nghttp2 --with-zlib && \
    make --jobs=$(nproc) && \
    make install


FROM debian:13-slim

# Specify the version of crictl to install
ARG CRICTL_VERSION="v1.33.0"

LABEL org.opencontainers.image.source=https://github.com/nosportugal/debug-pod
LABEL org.opencontainers.image.description="A debian image with some debugging tools installed."
LABEL org.opencontainers.image.authors="NOS Portugal"

WORKDIR /root

# use same dpkg path-exclude settings that come by default with ubuntu:focal
# image that we previously used
RUN echo 'path-exclude=/usr/share/locale/*/LC_MESSAGES/*.mo' >> /etc/dpkg/dpkg.cfg.d/excludes
RUN echo 'path-exclude=/usr/share/doc/*' >> /etc/dpkg/dpkg.cfg.d/excludes
RUN echo 'path-include=/usr/share/doc/*/copyright' >> /etc/dpkg/dpkg.cfg.d/excludes
RUN echo 'path-include=/usr/share/doc/*/changelog.Debian.*' >> /etc/dpkg/dpkg.cfg.d/excludes

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get full-upgrade --auto-remove --purge -y && \
    apt-get install -y \
        ca-certificates \
        curl \
        httping \
        man \
        man-db \
        vim \
        screen \
        gnupg \
        atop \
        htop \
        sysstat \
        jq \
        dnsutils \
        tcpdump \
        traceroute \
        iputils-ping \
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
        bpftool \
        nmap \
        redis-tools \
        kcat \
        nghttp2 \
        libpsl5t64 \
        zlib1g \
        wget && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/ /usr/local/

# Resolve any issues of C-level lib
# location caches ("shared library cache")
RUN ldconfig

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

# for hey 
RUN curl -Lv -o /usr/bin/hey https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64 && \
    chmod a+x /usr/bin/hey

# install speedtest cli from 
# https://www.speedtest.net/apps/cli
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt-get install -y speedtest

# add httpstat script
RUN curl -s https://raw.githubusercontent.com/b4b4r07/httpstat/master/httpstat.sh >/usr/bin/httpstat && chmod a+x /usr/bin/httpstat

# install AZ cli
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash && \
    apt-get install -y azure-cli

ENTRYPOINT [ "/bin/bash" ]
