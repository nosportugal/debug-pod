FROM debian:12-slim

LABEL maintainer="Slim Debug Pod"

# Install essential network debugging tools
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        # Basic network tools
        curl \
        wget \
        netcat-openbsd \
        telnet \
        iputils-ping \
        traceroute \
        dnsutils \
        iperf3 \
        socat \
        jq \
        openssl \
        # Analysis tools
        tcpdump \
        net-tools \
        iproute2 \
        lsof \
        # Basic utilities
        vim \
        nano \
        bash \
        procps && \
    # Cleanup to reduce size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Definir bash como shell padrão
SHELL ["/bin/bash", "-c"]

# Keep container running for debugging
CMD ["tail", "-f", "/dev/null"]