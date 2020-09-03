FROM fedora:32

RUN yum install postfix postfix-pgsql cyrus-sasl cyrus-sasl-plain supervisor -y && \
    yum clean all && \
    rm -rf /var/cache/yum

COPY conf /conf

CMD ["/usr/bin/supervisord","-c","/conf/supervisord.conf"]
