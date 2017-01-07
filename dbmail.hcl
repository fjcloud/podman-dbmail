max_stale = "2m"

template {
  source = "/root/pgpass.template"
  destination = "/root/.pgpass"
  perms = 0600
}

template {
  source = "/root/dbmail.conf.template"
  destination = "/etc/dbmail.conf"
}

exec {
  command = "/usr/local/bin/dbmail_start.sh"
  splay = "60s"
}
