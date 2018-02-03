max_stale = "2m"

template {
  source = "/root/templates/pgpass.template"
  destination = "/root/.pgpass"
  perms = 0600
}

template {
  source = "/root/templates/dbmail.conf.template"
  destination = "/etc/dbmail.conf"
}

template {
  source = "/root/templates/ssmtp.conf.template"
  destination = "/etc/ssmtp/ssmtp.conf"
}

exec {
  command = "/usr/local/bin/dbmail_start.sh"
  splay = "60s"
}
