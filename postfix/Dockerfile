FROM fedora:32

RUN yum install postfix postfix-pgsql cyrus-sasl cyrus-sasl-plain supervisor -y

COPY conf /conf

CMD ["/usr/bin/supervisord","-c","/conf/supervisord.conf"]
