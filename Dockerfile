FROM debian:8

ENV \
  CONSUL_TEMPLATE_VERSION=0.19.4 \
  CONSUL_TEMPLATE_SHA256=5f70a7fb626ea8c332487c491924e0a2d594637de709e5b430ecffc83088abc0 \

  DBMAIL_MAIN_VERSION=3.2 \
  DBMAIL_VERSION=3.2.3 \
  DBMAIL_SHA256=fd4d90e3e5ddb0c3fbdaa766d19d2464b5027a8c8d0b0df614418a3aac811832 \

  CONSUL_HTTP_ADDR= \
  CONSUL_TOKEN= \
  VAULT_ADDR= \
  VAULT_TOKEN= \

  DBMAIL_SERVICE= \

  USER_UID=1000 \
  USER_GID=1000 \

  SET_CONTAINER_TIMEZONE=true \
  CONTAINER_TIMEZONE=Europe/Moscow

RUN \
  apt-get update \

  && apt-get install --no-install-recommends --no-install-suggests -y \
    build-essential \
    ca-certificates \
    curl \
    libevent-dev \
    libglib2.0-dev \
    libgmime-2.6-dev \
    libmhash-dev \
    libpq-dev \
    libsieve2-dev \
    libzdb-dev \
    unzip \

  && apt-get install --no-install-recommends --no-install-suggests -y \
    libevent-2.0-5 \
    libevent-pthreads-2.0-5 \
    libglib2.0 \
    libgmime-2.6 \
    libmhash2 \
    libpq5 \
    libsieve2-1 \
    libzdb9 \
    ssmtp \

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

  && apt-get purge -y --auto-remove \
    build-essential \
    ca-certificates \
    curl \
    libevent-dev \
    libglib2.0-dev \
    libgmime-2.6-dev \
    libmhash-dev \
    libpq-dev \
    libsieve2-dev \
    libzdb-dev \
    unzip \

  && rm -rf /var/lib/apt/lists/*

COPY dbmail_start.sh /usr/local/bin/dbmail_start.sh
COPY templates /root/templates
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]
