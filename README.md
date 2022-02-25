# Docker Logging

A playground project to log NGINX via a Syslog-ng server that are both live inside a docker container.

# Quickstart

To run both run containers (nginx and syslog-ng), run:

```bash
make up
```

As it's clear in the `Makefile` file, it will build a new image `alielm/syslog-ng-alpine` if it doesn't exist, create a new , wait 2 seconds to make sure that 

1. build a new image `alielm/syslog-ng-alpine` if it doesn't exist;
2. create a new `syslog-ng` server container;
3. wait 2 seconds just to make sure our `syslog-ng` server is ready (it can be improved by adding a healthcheck) and finally,;
4. create a new `nginx` container with the `syslog` logging driver with the address of our `syslog-ng` server that we mapped its port (601/tcp) to our Docker host.

# Troubleshooting

When using the `syslog()` driver in a source, and the protocol is TCP, you might get this error: `Invalid frame header; header=''`

To solve this issue, change the driver to the `network()` driver with the `flag(syslog-protocol)` option.

Example:

```properties
source s_network_tcp {
    network(
        transport(tcp)
        flags(syslog-protocol)
        ...
    );
};
```

References
- https://discuss.elastic.co/t/logstash-ssl-tcp-syslog-ng-invalid-frame-header-header/118088
- https://www.syslog-ng.com/community/b/blog/posts/using-rfc5424-syslog-protocol-plain-tcp-rsyslog-syslog-ng
- https://support.oneidentity.com/syslog-ng-premium-edition/kb/280210/how-to-configure-bsd-syslog-and-ietf-syslog-message-formats-in-syslog-ng
- http://www.watersprings.org/pub/id/draft-gerhards-syslog-plain-tcp-03.html
- https://sflanders.net/2018/08/22/syslog-and-what-protocol-to-send-events-over/

# Important Note

> When receiving messages using the UDP protocol, increase the size of the UDP receive buffer on the receiver host (that is, the syslog-ng OSE server or relay receiving the messages). Note that on certain platforms, for example, on Red Hat Enterprise Linux 5, even low message load (~200 messages per second) can result in message loss, unless the `so-rcvbuf()` option of the source is increased. In such cases, you will need to increase the `net.core.rmem_max` parameter of the host (for example, to `1024000`), but do not modify `net.core.rmem_default` parameter.<br>As a general rule, increase the `so-rcvbuf()` so that the buffer size in kilobytes is higher than the rate of incoming messages per second. For example, to receive 2000 messages per second, set the `so-rcvbuf()` at least to `2 097 152` bytes.

Reference: https://www.syslog-ng.com/technical-documents/doc/syslog-ng-open-source-edition/3.22/administration-guide/20