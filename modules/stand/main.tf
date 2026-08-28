# =============================================================================
# Порядок: vm -> install -> pmm -> postgres -> mysql
# Первые три — синглтоны, последние два включаются списком engines
# =============================================================================

locals {
  pg_count    = contains(var.engines, "postgres") ? 1 : 0
  mysql_count = contains(var.engines, "mysql") ? 1 : 0

  # 192.168.56.50 -> 192.168.56
  stand_prefix    = join(".", slice(split(".", var.stand_ip), 0, 3))
  stand_cidr      = "${local.stand_prefix}.0/24"
  stand_host_mask = "${local.stand_prefix}.%"

  pg_conf_dir = "/etc/postgresql/${var.postgres_version}/main"
}

module "vm" {
  source = "../vm"

  providers = {
    vagrant = vagrant
  }

  vagrantfile_dir = var.vagrantfile_dir
  machine_name    = var.machine_name
}

module "install" {
  source = "../install"

  providers = {
    ssh = ssh
  }

  ssh                 = module.vm.ssh
  install_postgres    = local.pg_count == 1
  install_mysql       = local.mysql_count == 1
  postgres_version    = var.postgres_version
  percona_repo        = var.percona_repo
  percona_version     = var.percona_version
  mysql_root_password = var.mysql_root_password
  docker_tcp_port     = var.docker_tcp_port
}

module "pmm" {
  source = "../pmm"

  providers = {
    ssh     = ssh
    docker  = docker
    grafana = grafana
  }

  depends_on = [module.install]

  ssh            = module.vm.ssh
  stand_ip       = var.stand_ip
  server_version = var.pmm_version
  client_version = var.pmm_client_version
  admin_password = var.pmm_admin_password
}

module "postgres" {
  source = "../postgres"
  count  = local.pg_count

  providers = {
    ssh        = ssh
    postgresql = postgresql
  }

  # Регистрация сервиса требует настроенного агента.
  depends_on = [module.pmm]

  ssh                = module.vm.ssh
  conf_dir           = local.pg_conf_dir
  port               = var.postgres_port
  allowed_cidr       = local.stand_cidr
  superuser_password = var.postgres_password
  pmm_password       = var.pmm_db_password
  service_name       = "${var.service_prefix}-pg"

  users           = var.pg_users
  databases       = var.pg_databases
  user_privileges = var.pg_user_privileges
}

module "mysql" {
  source = "../mysql"
  count  = local.mysql_count

  providers = {
    ssh   = ssh
    mysql = mysql
  }

  depends_on = [module.pmm, module.postgres]

  ssh           = module.vm.ssh
  port          = var.mysql_port
  tf_password   = var.mysql_tf_password
  tf_host_mask  = local.stand_host_mask
  app_host_mask = local.stand_host_mask
  pmm_password  = var.pmm_db_password
  service_name  = "${var.service_prefix}-mysql"

  users           = var.mysql_users
  databases       = var.mysql_databases
  user_privileges = var.mysql_user_privileges
}
