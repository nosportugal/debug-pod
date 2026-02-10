# debug-pod

> The ultimate Kubernetes debugging toolkit — a single container image packed with everything you need to investigate, diagnose, and troubleshoot your clusters.

Built on **Debian 13 (Trixie)** with a custom **curl 8.18** compiled with **HTTP/3 (QUIC)** support.

## What is this?

When something goes wrong inside a Kubernetes cluster, you often need tools that aren't available in your application containers. Instead of installing dozens of packages into your workloads, just drop a debug pod into any namespace and start investigating immediately.

This image is maintained by [NOS Portugal](https://github.com/nosportugal) and originally inspired by DigitalOcean's [doks-debug](https://github.com/digitalocean/doks-debug) project.

---

## Quick Start

### One-liner

Spin up an interactive debug shell in your current namespace:

```bash
kubectl run --rm -it debug-pod \
  --pod-running-timeout=300s \
  --image=ghcr.io/nosportugal/debug-pod:master
```

### Shell alias (recommended)

Add this to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.) for one-word access:

```bash
alias debug-pod='kubectl run --rm -it debug-pod --pod-running-timeout=300s --image=ghcr.io/nosportugal/debug-pod:master'
```

Then you can jump into any cluster and namespace instantly:

```bash
debug-pod --context production -n my-app
```

### Using `kubectl debug` (Kubernetes 1.25+)

Attach a debug container to a running pod without restarting it:

```bash
kubectl debug -it <pod-name> \
  --image=ghcr.io/nosportugal/debug-pod:master \
  --target=<container-name>
```

### Advanced: DaemonSet / Deployment

For persistent debugging across nodes, use the provided manifests in the [`k8s/`](k8s/) directory:

```bash
# Deploy to every node as a DaemonSet (privileged, host-networked)
kubectl apply -f k8s/daemonset.yaml

# Or deploy a single replica
kubectl apply -f k8s/deployment.yaml
```

These manifests run in `kube-system` with `hostPID`, `hostNetwork`, `hostIPC`, and a host filesystem mount at `/host` — ideal for deep node-level debugging. They also mount the containerd socket for `crictl` access.

---

## Tooling

The image ships with **40+ tools** organized by category. Everything is ready to use out of the box.

### HTTP & API

| Tool | Description |
|------|-------------|
| [`curl`](https://github.com/curl/curl) | HTTP client built from source with **HTTP/3 (QUIC)** support via ngtcp2/nghttp3 and OpenSSL 3.5 |
| [`httpie`](https://httpie.io/) | User-friendly HTTP client with JSON support, syntax highlighting, and intuitive CLI |
| [`wget`](https://www.gnu.org/software/wget/) | File retrieval via HTTP, HTTPS, FTP, and FTPS |
| [`httpstat`](https://github.com/b4b4r07/httpstat) | curl statistics visualizer — shows DNS, TCP, TLS, and transfer timings at a glance |
| [`httping`](https://github.com/flok99/httping) | Measures HTTP(S) latency and throughput to a web server |

### DNS & Network Diagnostics

| Tool | Description |
|------|-------------|
| [`dnsutils`](https://packages.debian.org/trixie/dnsutils) | DNS client tools: `dig`, `nslookup`, `nsupdate` |
| [`iputils-ping`](https://packages.debian.org/trixie/iputils-ping) | `ping` — ICMP reachability testing |
| [`traceroute`](https://linux.die.net/man/8/traceroute) | Trace the route packets take to a host |
| [`mtr`](https://github.com/traviscross/mtr) | Combines `traceroute` and `ping` in a single real-time diagnostic |
| [`nmap`](https://nmap.org/) | Network exploration and port scanning |
| [`ncat`](https://nmap.org/ncat/) | Nmap's netcat — TCP/UDP connections, port scanning, proxying |
| [`telnet`](https://linux.die.net/man/1/telnet) | Quick TCP connectivity checks |
| [`tcpdump`](https://www.tcpdump.org/) | Packet capture and analysis |
| [`dsniff`](https://www.monkey.org/~dugsong/dsniff/) | Network auditing and penetration testing tools |

### Network Configuration

| Tool | Description |
|------|-------------|
| [`iproute2`](https://wiki.linuxfoundation.org/networking/iproute2) | Modern Linux networking: `ip`, `ss`, `tc`, `bridge` |
| [`net-tools`](https://packages.debian.org/trixie/net-tools) | Classic networking: `ifconfig`, `netstat`, `arp`, `route` |
| [`conntrack`](https://conntrack-tools.netfilter.org/) | Inspect and manage Netfilter connection tracking entries |

### TLS & Security

| Tool | Description |
|------|-------------|
| [`openssl`](https://www.openssl.org/) | TLS/SSL toolkit — inspect certificates, test connections, generate keys |
| [`gnupg`](https://gnupg.org/) | GPG encryption and signing |

### Performance & Monitoring

| Tool | Description |
|------|-------------|
| [`htop`](https://htop.dev/) | Interactive process viewer |
| [`atop`](https://www.atoptool.nl/) | Advanced system and process monitor with historical data |
| [`sysstat`](https://github.com/sysstat/sysstat) | `sar`, `iostat`, `mpstat`, `pidstat` — CPU, memory, I/O, and network stats |
| [`hey`](https://github.com/rakyll/hey) | HTTP load generator and benchmarking tool |
| [`speedtest`](https://www.speedtest.net/apps/cli) | Ookla's Speedtest CLI for internet bandwidth testing |

### System & Process Debugging

| Tool | Description |
|------|-------------|
| [`strace`](https://github.com/strace/strace) | Trace system calls and signals between processes and the kernel |
| [`bpftool`](https://github.com/libbpf/bpftool) | Inspect and manipulate eBPF programs and maps |
| [`psmisc`](https://gitlab.com/psmisc/psmisc) | Process utilities: `pstree`, `killall`, `fuser` |

### Data Services

| Tool | Description |
|------|-------------|
| [`kcat`](https://github.com/edenhill/kcat) | Apache Kafka producer and consumer (formerly kafkacat) |
| [`redis-tools`](https://redis.io/docs/getting-started/) | `redis-cli` — connect and interact with Redis instances |

### Kubernetes & Container Runtime

| Tool | Description |
|------|-------------|
| [`crictl`](https://github.com/kubernetes-sigs/cri-tools/blob/master/docs/crictl.md) | CRI-compatible container runtime CLI, pre-configured for containerd |

### Cloud CLI

| Tool | Description |
|------|-------------|
| [`az`](https://learn.microsoft.com/en-us/cli/azure/) | Azure CLI for managing Azure resources directly from the pod |

### General Utilities

| Tool | Description |
|------|-------------|
| [`vim`](https://github.com/vim/vim) | Powerful text editor |
| [`screen`](https://www.gnu.org/software/screen/) | Terminal multiplexer for managing multiple shell sessions |
| [`jq`](https://github.com/stedolan/jq) | Lightweight command-line JSON processor |
| [`man`](https://linux.die.net/man/) | Manual pages for installed tools |

---

## Tips and Tricks

### Access the host filesystem

When running with the provided DaemonSet / Deployment manifests, the host root filesystem is mounted at `/host`. You can chroot into it to interact with the node directly:

```bash
chroot /host /bin/bash
```

### Inspect kubelet and system services

After chrooting into the host:

```bash
systemctl status kubelet
journalctl -u kubelet --since "5 minutes ago"
journalctl -u containerd -f
```

### Test HTTP/3 (QUIC) connectivity

```bash
curl --http3 -I https://cloudflare.com
curl --http3 -I https://google.com
```

### Inspect TLS certificates

```bash
# Check a remote certificate
openssl s_client -connect example.com:443 -servername example.com </dev/null 2>/dev/null | openssl x509 -noout -text

# Quick expiry check
openssl s_client -connect example.com:443 -servername example.com </dev/null 2>/dev/null | openssl x509 -noout -dates
```

### DNS troubleshooting

```bash
dig example.com
dig @8.8.8.8 example.com +short
nslookup my-service.my-namespace.svc.cluster.local
```

### Capture and analyze traffic

```bash
# Capture DNS traffic
tcpdump -i any port 53 -nn

# Capture HTTP traffic to a specific host
tcpdump -i any host 10.0.0.1 and port 80 -A
```

### Kafka operations

```bash
# List topics
kcat -b kafka-broker:9092 -L

# Consume messages
kcat -b kafka-broker:9092 -t my-topic -C -o beginning -c 10
```

### Container runtime inspection

```bash
# List running containers
crictl ps

# Get container logs
crictl logs <container-id>

# Inspect a pod sandbox
crictl inspectp <pod-id>
```

### HTTP load testing

```bash
# Send 1000 requests with 50 concurrent workers
hey -n 1000 -c 50 https://my-service:8080/health
```

### Visualize HTTP timing

```bash
httpstat https://my-service:8080/api/health
```

---

## Building locally

```bash
docker buildx build --platform "linux/amd64" --output type=docker --tag debug-pod -f Dockerfile .
```

---

## Credits

Originally forked from [digitalocean/doks-debug](https://github.com/digitalocean/doks-debug). Maintained by [NOS Portugal](https://github.com/nosportugal).
