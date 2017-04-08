FROM debian:8

ENV CONSUL_TEMPLATE_VERSION=0.18.2
ENV CONSUL_TEMPLATE_SHA256=6fee6ab68108298b5c10e01357ea2a8e4821302df1ff9dd70dd9896b5c37217c

ENV DBMAIL_MAIN_VERSION=3.2
ENV DBMAIL_VERSION=3.2.3
ENV DBMAIL_SHA256=fd4d90e3e5ddb0c3fbdaa766d19d2464b5027a8c8d0b0df614418a3aac811832

RUN \
  apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
  curl unzip ca-certificates build-essential libpq-dev \
  libglib2.0-dev libgmime-2.6-dev libsieve2-dev libmhash-dev libevent-dev \
  libzdb-dev \

  && apt-get install --no-install-recommends --no-install-suggests -y \
  ssmtp libpq5 libglib2.0 libgmime-2.6 libsieve2-1 libmhash2 libevent-2.0-5 \
  libevent-pthreads-2.0-5 libzdb9 \

  && cd /usr/local/bin \
  && curl -L https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -o consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && echo -n "$CONSUL_TEMPLATE_SHA256  consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" | sha256sum -c - \
  && unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && rm consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \

  && curl -L http://www.dbmail.org/download/$DBMAIL_MAIN_VERSION/dbmail-${DBMAIL_VERSION}.tar.gz -o dbmail-${DBMAIL_VERSION}.tar.gz \
  && echo -n "$DBMAIL_SHA256  dbmail-${DBMAIL_VERSION}.tar.gz" | sha256sum -c - \
  && tar -zxf dbmail-${DBMAIL_VERSION}.tar.gz \
  && rm dbmail-${DBMAIL_VERSION}.tar.gz \
  && cd dbmail-${DBMAIL_VERSION} \
  && ./configure --with-sieve \
  && make all && make install \
  && rm -rf /usr/local/bin/dbmail-${DBMAIL_VERSION} \

  && ln -sf /proc/1/fd/2 /var/log/dbmail.err \
  && ln -sf /proc/1/fd/1 /var/log/dbmail.log \

  && apt-get purge -y --auto-remove curl unzip ca-certificates build-essential \
  libpq-dev libglib2.0-dev libgmime-2.6-dev libsieve2-dev libmhash-dev \
  libevent-dev libzdb-dev \
  && rm -rf /var/lib/apt/lists/*

COPY dbmail_start.sh /usr/local/bin/dbmail_start.sh
COPY dbmail.hcl /etc/dbmail.hcl
COPY dbmail.conf.template /root/dbmail.conf.template
COPY pgpass.template /root/pgpass.template
COPY ssmtp.conf.template /root/ssmtp.conf.template

ENV CONSUL_HTTP_ADDR=
ENV CONSUL_TOKEN=
ENV VAULT_ADDR=
ENV VAULT_TOKEN=
ENV DBMAIL_SERVICE=

ENV USER_UID=1000
ENV USER_GID=1000

CMD ["/usr/local/bin/consul-template", "-config", "/etc/dbmail.hcl"]
