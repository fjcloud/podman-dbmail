FROM debian:8

COPY consul-template_0.16.0_SHA256SUMS /usr/local/bin/consul-template_0.16.0_SHA256SUMS
COPY dbmail-3.2.3.tar.gz_SHA256SUMS /usr/local/bin/dbmail-3.2.3.tar.gz_SHA256SUMS

RUN \
  apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
  curl unzip ca-certificates build-essential libpq-dev \
  libglib2.0-dev libgmime-2.6-dev libsieve2-dev libmhash-dev libevent-dev \
  libzdb-dev \

  && cd /usr/local/bin \
  && curl -L https://releases.hashicorp.com/consul-template/0.16.0/consul-template_0.16.0_linux_amd64.zip -o consul-template_0.16.0_linux_amd64.zip \
  && sha256sum -c consul-template_0.16.0_SHA256SUMS \
  && unzip consul-template_0.16.0_linux_amd64.zip \
  && rm consul-template_0.16.0_linux_amd64.zip consul-template_0.16.0_SHA256SUMS \

  && curl -L http://www.dbmail.org/download/3.2/dbmail-3.2.3.tar.gz -o dbmail-3.2.3.tar.gz \
  && sha256sum -c dbmail-3.2.3.tar.gz_SHA256SUMS \
  && tar -zxf dbmail-3.2.3.tar.gz \
  && rm dbmail-3.2.3.tar.gz dbmail-3.2.3.tar.gz_SHA256SUMS \
  && cd dbmail-3.2.3 \
  && ./configure --with-sieve \
  && make all && make install \
  && rm -rf /usr/local/bin/dbmail-3.2.3 \

  && ln -sf /proc/1/fd/2 /var/log/dbmail.err \
  && ln -sf /proc/1/fd/1 /var/log/dbmail.log \

  && apt-get remove -y curl unzip ca-certificates build-essential libpq-dev \
  libglib2.0-dev libgmime-2.6-dev libsieve2-dev libmhash-dev libevent-dev \
  libzdb-dev \
  && rm -rf /var/lib/apt/lists/*

COPY dbmail_start.sh /usr/local/bin/dbmail_start.sh
COPY dbmail.hcl /etc/dbmail.hcl
COPY dbmail.conf.template /root/dbmail.conf.template
COPY pgpass.template /root/pgpass.template

ENV CONSUL_HTTP_ADDR=
ENV CONSUL_TOKEN=
ENV VAULT_ADDR=
ENV VAULT_TOKEN=
ENV DBMAIL_SERVICE=

ENV USER_UID=1000
ENV USER_GID=1000

CMD consul-template -config /etc/dbmail.hcl
