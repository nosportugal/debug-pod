# match doks-debug version with DOKS worker node image version for kernel
# tooling compatibility reasons
FROM debian:11-slim

LABEL org.opencontainers.image.source=https://github.com/nosportugal/debug-pod
LABEL org.opencontainers.image.description="A debian image with some debugging tools installed."

WORKDIR /root

# use same dpkg path-exclude settings that come by default with ubuntu:focal
# image that we previously used
RUN echo 'path-exclude=/usr/share/locale/*/LC_MESSAGES/*.mo' > /etc/dpkg/dpkg.cfg.d/excludes
RUN echo 'path-exclude=/usr/share/doc/*' > /etc/dpkg/dpkg.cfg.d/excludes
RUN echo 'path-include=/usr/share/doc/*/copyright' > /etc/dpkg/dpkg.cfg.d/excludes
RUN echo 'path-include=/usr/share/doc/*/changelog.Debian.*' > /etc/dpkg/dpkg.cfg.d/excludes

RUN echo 'deb http://deb.debian.org/debian bullseye-backports main' > /etc/apt/sources.list.d/backports.list

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
                       net-tools \
                       netcat \
                       iproute2 \
                       strace \
                       telnet \
                       openssl \
                       psmisc \
                       dsniff \
                       mtr-tiny \
                       conntrack \
                       bpftool \
                       nmap

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

ENTRYPOINT [ "/bin/bash" ]
