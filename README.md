# The ultimate debug pod

A Docker image based on Debian 13 (Trixie) with Kubernetes tooling for investigation and troubleshooting your cluster.

## Purpose

This is an image based on the DOKS team's pod, full of tooling to make diagnostics and tests inside a container/kubernetes pod.

This way you won't have to install a bunch of tooling on your pods.

## Usage

The easiest way to start a pod in the current context and namespace is:

```bash
kubectl run --rm -it debug-pod --pod-running-timeout 300 --image=ghcr.io/nosportugal/debug-pod:master
```

You can also have at hand this nice alias:

```bash
alias debug-pod='kubectl run --rm -it debug-pod --pod-running-timeout 300 --image=ghcr.io/nosportugal/debug-pod:master'
```

Then you can do stuff from anywhere. The most useful example that I can think of is:

```bash
debug-pod --context some-cluster -n some-namespace
```

## Tooling

Once you're in, you have access to the set of tools listed in the `Dockerfile`. This includes:

 - [`vim`](https://github.com/vim/vim) - is a greatly improved version of the good old UNIX editor Vi. 
 - [`screen`](https://www.gnu.org/software/screen/) - is a full-screen window manager that multiplexes a physical terminal between several processes, typically interactive shells.
 - [`curl`](https://github.com/curl/curl) - is a command-line tool for transferring data specified with URL syntax. Built from source with **HTTP/3 (QUIC)** support via ngtcp2/nghttp3 and OpenSSL 3.5.
 - [`jq`](https://github.com/stedolan/jq) - is a lightweight and flexible command-line JSON processor.
 - [`dnsutils`](https://packages.debian.org/stretch/dnsutils) - includes various client programs related to DNS that are derived from the BIND source tree, specifically [`dig`](https://linux.die.net/man/1/dig), [`nslookup`](https://linux.die.net/man/1/nslookup), and [`nsupdate`](https://linux.die.net/man/8/nsupdate).
 - [`iputils-ping`](https://packages.debian.org/stretch/iputils-ping) - includes the [`ping`](https://linux.die.net/man/8/ping) tool that sends ICMP `ECHO_REQUEST` packets to a host in order to test if the host is reachable via the network.
 - [`tcpdump`](https://www.tcpdump.org/) - a powerful command-line packet analyzer; and libpcap, a portable C/C++ library for network traffic capture.
 - [`traceroute`](https://linux.die.net/man/8/traceroute) - tracks the route packets taken from an IP network on their way to a given host.
 - [`net-tools`](https://packages.debian.org/stretch/net-tools) - includes the important tools for controlling the network subsystem of the Linux kernel, specifically [`arp`](http://man7.org/linux/man-pages/man8/arp.8.html), [`ifconfig`](https://linux.die.net/man/8/ifconfig), and [`netstat`](https://linux.die.net/man/8/netstat).
 - [`ncat`](https://nmap.org/ncat/) - Nmap's netcat replacement. A multi-tool for interacting with TCP and UDP; it can open TCP connections, send UDP packets, listen on arbitrary TCP and UDP ports, do port scanning, and deal with both IPv4 and IPv6.
 - [`iproute2`](https://wiki.linuxfoundation.org/networking/iproute2) - is a collection of utilities for controlling TCP / IP networking and traffic control in Linux.
 - [`strace`](https://github.com/strace/strace) - is a diagnostic, debugging and instructional userspace utility with a traditional command-line interface for Linux. It is used to monitor and tamper with interactions between processes and the Linux kernel, which include system calls, signal deliveries, and changes of process state.
 - [`sysstat`](https://github.com/sysstat/sysstat) - a collection of performance monitoring tools including `sar`, `iostat`, `mpstat`, `pidstat`, and `tapestat`. Useful for monitoring CPU, memory, I/O, and network statistics.
 - [`htop`](https://hisham.hm/htop/) - is interactive process viewer for Unix systems.
 - [`atop`](https://www.atoptool.nl/) - is an advanced interactive monitor for Linux-systems to view the load on system-level and process-level.
 - [`wget`](https://www.gnu.org/software/wget/) - for retrieving files using HTTP, HTTPS, FTP and FTPS.
 - [`httping`](https://github.com/flok99/httping) - measures latency and throughput of a web server by sending HTTP(S) requests.
 - [`telnet`](https://linux.die.net/man/1/telnet) - communicates with another host using the TELNET protocol. Useful for testing TCP connectivity.
 - [`openssl`](https://www.openssl.org/) - a toolkit for TLS/SSL protocols and general-purpose cryptography. Useful for inspecting certificates and testing TLS connections.
 - [`mtr`](https://github.com/traviscross/mtr) - combines the functionality of traceroute and ping in a single network diagnostic tool.
 - [`nmap`](https://nmap.org/) - a network exploration tool and security / port scanner.
 - [`conntrack`](https://conntrack-tools.netfilter.org/) - a tool for interacting with the Netfilter connection tracking system.
 - [`bpftool`](https://github.com/libbpf/bpftool) - a tool for inspection and manipulation of eBPF programs and maps.
 - [`dsniff`](https://www.monkey.org/~dugsong/dsniff/) - a collection of network auditing and penetration testing tools.
 - [`kcat`](https://github.com/edenhill/kcat) - a generic non-JVM Apache Kafka producer and consumer (formerly kafkacat).
 - [`redis-tools`](https://redis.io/docs/getting-started/) - includes `redis-cli`, the Redis command-line client.
 - [`httpie`](https://httpie.io/) - a user-friendly HTTP client for the API era with JSON support, syntax highlighting, and more.
 - [`hey`](https://github.com/rakyll/hey) - an HTTP load generator and benchmarking tool.
 - [`speedtest`](https://www.speedtest.net/apps/cli) - Ookla's Speedtest CLI for testing internet bandwidth.
 - [`httpstat`](https://github.com/b4b4r07/httpstat) - a curl statistics visualizer that shows DNS lookup, TCP connection, TLS handshake, and transfer timings.
 - [`az`](https://learn.microsoft.com/en-us/cli/azure/) - the Azure CLI for managing Azure resources.
 - [`crictl`](https://github.com/kubernetes-sigs/cri-tools/blob/master/docs/crictl.md) - a CLI for CRI endpoints. Configured to use `/run/containerd/containerd.sock` as a default endpoint.

## Tips and Tricks

### chroot + systemctl

```bash
chroot /host /bin/bash
systemctl status kubelet
journalctl -xe
journalctl -u kubelet
```
