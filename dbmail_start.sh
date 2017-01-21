#!/usr/bin/env sh

userdel dbmail 2>/dev/null
groupdel dbmail 2>/dev/null
groupadd -g $USER_GID dbmail
useradd -d /home/dbmail -g dbmail -u $USER_UID dbmail

mkdir -p /var/run/dbmail
chown dbmail:dbmail /var/run/dbmail

# Foreground mode (-D -n) in dbmail works incorrect
# Daemons didn't listening ports
# So use background mode

pidfile=""

if [ "$DBMAIL_SERVICE" = "imapd" ]; then
  dbmail-imapd -f /etc/dbmail.conf
  pidfile="dbmail-imapd.pid"
elif [ "$DBMAIL_SERVICE" = "lmtpd" ]; then
  dbmail-lmtpd -f /etc/dbmail.conf
  pidfile="dbmail-lmtpd.pid"
elif [ "$DBMAIL_SERVICE" = "timsieved" ]; then
  dbmail-timsieved -f /etc/dbmail.conf
  pidfile="dbmail-timsieved.pid"
fi

# Wait daemons start
sleep 2

child=`cat /var/run/dbmail/$pidfile`

trap "kill $child" INT TERM

anywait(){
  for pid in "$@"; do
    while kill -0 "$pid"; do
      sleep 1
    done
  done
}

anywait $child
