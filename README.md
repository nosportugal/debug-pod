# The ultimate debug pod

A Docker image with Kubernetes toolink for investigation and troubleshooting your cluster.

![main build](https://github.com/digitalocean/doks-debug/actions/workflows/test.yaml/badge.svg) ![main release](https://github.com/digitalocean/doks-debug/actions/workflows/release.yaml/badge.svg)

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
 - [`curl`](https://github.com/curl/curl) - is a command-line tool for transferring data specified with URL syntax.
 - [`jq`](https://github.com/stedolan/jq) - is a lightweight and flexible command-line JSON processor.
 - [`dnsutils`](https://packages.debian.org/stretch/dnsutils) - includes various client programs related to DNS that are derived from the BIND source tree, specifically [`dig`](https://linux.die.net/man/1/dig), [`nslookup`](https://linux.die.net/man/1/nslookup), and [`nsupdate`](https://linux.die.net/man/8/nsupdate).
 - [`iputils-ping`](https://packages.debian.org/stretch/iputils-ping) - includes the [`ping`](https://linux.die.net/man/8/ping) tool that sends ICMP `ECHO_REQUEST` packets to a host in order to test if the host is reachable via the network.
 - [`tcpdump`](https://www.tcpdump.org/) - a powerful command-line packet analyzer; and libpcap, a portable C/C++ library for network traffic capture.
 - [`traceroute`](https://linux.die.net/man/8/traceroute) - tracks the route packets taken from an IP network on their way to a given host.
 - [`net-tools`](https://packages.debian.org/stretch/net-tools) - includes the important tools for controlling the network subsystem of the Linux kernel, specifically [`arp`](http://man7.org/linux/man-pages/man8/arp.8.html), [`ifconfig`](https://linux.die.net/man/8/ifconfig), and [`netstat`](https://linux.die.net/man/8/netstat).
 - [`netcat`](https://linux.die.net/man/1/nc) - is a multi-tool for interacting with TCP and UDP; it can open TCP connections, send UDP packets, listen on arbitrary TCP and UDP ports, do port scanning, and deal with both IPv4 and IPv6.
 - [`iproute2`](https://wiki.linuxfoundation.org/networking/iproute2) - is a collection of utilities for controlling TCP / IP networking and traffic control in Linux.
 - [`strace`](https://github.com/strace/strace) - is a diagnostic, debugging and instructional userspace utility with a traditional command-line interface for Linux. It is used to monitor and tamper with interactions between processes and the Linux kernel, which include system calls, signal deliveries, and changes of process state.
 - [`docker`](https://docs.docker.com/engine/reference/commandline/cli/) - is the CLI tool used for interacting with Docker containers on the system.
 - [`dstat`](http://dag.wiee.rs/home-made/dstat/) - is a versatile replacement for vmstat, iostat, netstat and ifstat. Dstat overcomes some of their limitations and adds some extra features, more counters and flexibility. Dstat is handy for monitoring systems during performance tuning tests, benchmarks or troubleshooting.
 - [`htop`](https://hisham.hm/htop/) - is interactive process viewer for Unix systems.
 - [`atop`](https://www.atoptool.nl/) - is an advanced interactive monitor for Linux-systems to view the load on system-level and process-level.
