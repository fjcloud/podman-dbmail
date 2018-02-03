#!/usr/bin/env sh

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
elif [ "$DBMAIL_SERVICE" = "pop" ]; then
  dbmail-pop3d -f /etc/dbmail.conf
  pidfile="dbmail-pop3d.pid"
fi

# Wait daemons start
sleep 2

child=`cat /var/run/dbmail/$pidfile`

trap "kill $child" INT TERM

while true; do
  kill -0 "$child"
  if [ "$?" = "0" ]; then
    sleep 5
  else
    echo "Exited"
    exit
  fi
done
