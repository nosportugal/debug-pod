FROM debian:12 AS builder

# this builder part is the work of Yury Muski, from https://github.com/yurymuski/curl-http3
LABEL maintainer="Yury Muski <muski.yury@gmail.com>"

WORKDIR /opt

ARG CURL_VERSION=curl-8_2_1
# https://github.com/curl/curl/blob/master/docs/HTTP3.md#quiche-version
ARG QUICHE_VERSION=0.18.0

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get full-upgrade --auto-remove --purge -y && \
    apt-get install -y build-essential git autoconf libtool cmake golang-go curl libnghttp2-dev zlib1g-dev;


# install rust & cargo
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y -q;

RUN git clone --recursive https://github.com/cloudflare/quiche

# build quiche
RUN export PATH="$HOME/.cargo/bin:$PATH" && \
    cd quiche && \
    git checkout $QUICHE_VERSION && \
    cargo build --package quiche --release --features ffi,pkg-config-meta,qlog && \
    mkdir quiche/deps/boringssl/src/lib && \
    ln -vnf $(find target/release -name libcrypto.a -o -name libssl.a) quiche/deps/boringssl/src/lib/

# add curl
RUN git clone https://github.com/curl/curl
RUN cd curl && \
    git checkout $CURL_VERSION && \
    autoreconf -fi && \
    ./configure LDFLAGS="-Wl,-rpath,/opt/quiche/target/release" --with-openssl=/opt/quiche/quiche/deps/boringssl/src --with-quiche=/opt/quiche/target/release --with-nghttp2 --with-zlib && \
    make && \
    make DESTDIR="/debian/" install


# match doks-debug version with DOKS worker node image version for kernel
# tooling compatibility reasons
FROM debian:stable-slim

LABEL org.opencontainers.image.source=https://github.com/nosportugal/debug-pod
LABEL org.opencontainers.image.description="A debian image with some debugging tools installed."
LABEL org.opencontainers.image.authors="NOS Portugal"

WORKDIR /root

# use same dpkg path-exclude settings that come by default with ubuntu:focal
# image that we previously used
RUN echo 'path-exclude=/usr/share/locale/*/LC_MESSAGES/*.mo' > /etc/dpkg/dpkg.cfg.d/excludes
RUN echo 'path-exclude=/usr/share/doc/*' > /etc/dpkg/dpkg.cfg.d/excludes
RUN echo 'path-include=/usr/share/doc/*/copyright' > /etc/dpkg/dpkg.cfg.d/excludes
RUN echo 'path-include=/usr/share/doc/*/changelog.Debian.*' > /etc/dpkg/dpkg.cfg.d/excludes

RUN echo 'deb http://deb.debian.org/debian bullseye-backports main' > /etc/apt/sources.list.d/backports.list

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get full-upgrade --auto-remove --purge -y && \
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        software-properties-common \
        httping \
        man \
        man-db \
        vim \
        screen \
        gnupg \
        atop \
        htop \
        dstat \
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
        kafkacat \
        nghttp2 \
        zlib1g && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /debian/usr/local/ /usr/local/
COPY --from=builder /opt/quiche/target/release /opt/quiche/target/release

# Resolve any issues of C-level lib
# location caches ("shared library cache")
RUN ldconfig

RUN install -m 0755 -d /etc/apt/keyrings && \
    . /etc/os-release && \
    curl -fsSL "https://download.docker.com/linux/$ID/gpg" | gpg --dearmor -o "/etc/apt/keyrings/$ID.gpg" && \
    chmod a+r "/etc/apt/keyrings/$ID.gpg" && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/$ID.gpg] https://download.docker.com/linux/$ID $VERSION_CODENAME stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update -qq && \
    apt-get install -y docker-ce

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

ENTRYPOINT [ "/bin/bash" ]
