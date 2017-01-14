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
dbmail-imapd -f /etc/dbmail.conf
dbmail-lmtpd -f /etc/dbmail.conf
dbmail-timsieved -f /etc/dbmail.conf

# Wait daemons start
sleep 2

child1=`cat /var/run/dbmail/dbmail-imapd.pid`
child2=`cat /var/run/dbmail/dbmail-lmtpd.pid`
child3=`cat /var/run/dbmail/dbmail-timsieved.pid`

echo "Childs: $child1 $child2 $child3"

trap "kill $child1 $child2 $child3" INT TERM

anywait(){
  for pid in "$@"; do
    while kill -0 "$pid"; do
      sleep 1
    done
  done
}

anywait $child1 $child2 $child3
