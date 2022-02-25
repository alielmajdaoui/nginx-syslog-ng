FROM alpine
LABEL maintainer="Ali El Majdaoui"

RUN apk add --update --no-cache \ 
        syslog-ng \
        logger \
        netcat-openbsd \
        ; \
    apk del --purge; \
    rm -rf /tmp/*

COPY syslog-ng.conf /etc/syslog-ng/syslog-ng.conf

EXPOSE 601/tcp 514/udp 

CMD ["/usr/sbin/syslog-ng", "--foreground", "-f", "/etc/syslog-ng/syslog-ng.conf"]