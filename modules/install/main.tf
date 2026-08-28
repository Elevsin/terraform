locals {
  pg_count    = var.install_postgres ? 1 : 0
  mysql_count = var.install_mysql ? 1 : 0
}

# =============================================================================
# PostgreSQL — из штатного репозитория Debian
# =============================================================================

resource "ssh_resource" "postgres" {
  count = local.pg_count

  host        = var.ssh.host
  port        = var.ssh.port
  user        = var.ssh.user
  private_key = var.ssh.private_key
  timeout     = "5m"

  commands = [
    "sudo apt-get update -y",
    "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql-${var.postgres_version}",
    "sudo -u postgres psql -tAc 'SHOW server_version'",
  ]
}

# =============================================================================
# Репозиторий Percona
# =============================================================================

resource "ssh_resource" "percona_repo" {
  depends_on = [ssh_resource.postgres]

  host        = var.ssh.host
  port        = var.ssh.port
  user        = var.ssh.user
  private_key = var.ssh.private_key
  timeout     = "5m"

  commands = [
    "sudo apt-get update -y",
    "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y wget gnupg lsb-release ca-certificates",
    "wget -q -O /tmp/percona-release.deb https://repo.percona.com/apt/percona-release_latest.generic_all.deb",
    "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y /tmp/percona-release.deb",
  ]
}

# =============================================================================
# Percona Server — из репозитория Percona (в Debian его нет)
# =============================================================================

resource "ssh_resource" "mysql" {
  count      = local.mysql_count
  depends_on = [ssh_resource.percona_repo]

  host        = var.ssh.host
  port        = var.ssh.port
  user        = var.ssh.user
  private_key = var.ssh.private_key
  timeout     = "10m"

  file {
    content     = "[client]\nuser=root\npassword=\"${var.mysql_root_password}\"\n"
    destination = "/home/vagrant/.my.cnf"
    permissions = "0600"
  }

  commands = [
    "sudo percona-release setup -y ${var.percona_repo}",
    "sudo apt-get update -y",
    "echo 'percona-server-server percona-server-server/root-pass password ${var.mysql_root_password}' | sudo debconf-set-selections",
    "echo 'percona-server-server percona-server-server/re-root-pass password ${var.mysql_root_password}' | sudo debconf-set-selections",
    "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y percona-server-server=${var.percona_version} percona-server-client=${var.percona_version} percona-server-common=${var.percona_version}",
    "mysql -e 'SELECT VERSION()'",
  ]
}

# =============================================================================
# Docker Engine + демон на TCP
# =============================================================================

resource "ssh_resource" "docker" {
  depends_on = [ssh_resource.mysql, ssh_resource.percona_repo]

  host        = var.ssh.host
  port        = var.ssh.port
  user        = var.ssh.user
  private_key = var.ssh.private_key
  timeout     = "5m"

  commands = [
    "curl -fsSL https://get.docker.com -o /tmp/get-docker.sh",
    "sudo sh /tmp/get-docker.sh",
    "sudo usermod -aG docker vagrant",
    "sudo mkdir -p /etc/systemd/system/docker.service.d",
    "printf '[Service]\\nExecStart=\\nExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:${var.docker_tcp_port}\\n' | sudo tee /etc/systemd/system/docker.service.d/override.conf",
    "sudo systemctl daemon-reload",
    "sudo systemctl restart docker",
    "sudo docker --version",
  ]
}
