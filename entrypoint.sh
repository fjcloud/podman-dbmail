#!/usr/bin/env sh

if [ "$SET_CONTAINER_TIMEZONE" = "true" ]; then
    echo ${CONTAINER_TIMEZONE} >/etc/timezone \
    && ln -sf /usr/share/zoneinfo/${CONTAINER_TIMEZONE} /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata
    echo "Container timezone set to: $CONTAINER_TIMEZONE"
else
    echo "Container timezone not modified"
fi

userdel dbmail 2>/dev/null
groupdel dbmail 2>/dev/null
groupadd -g $USER_GID dbmail
useradd -d /home/dbmail -g dbmail -u $USER_UID dbmail

mkdir -p /var/run/dbmail
chown dbmail:dbmail /var/run/dbmail

consul-template -config /root/templates/service.hcl &
child=$!

trap "kill -s INT $child" INT TERM
wait "$child"
trap - INT TERM
wait "$child"
