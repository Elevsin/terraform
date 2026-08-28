# =============================================================================
# Вызов стенда
# =============================================================================

module "stand" {
  source = "../../modules/stand"

  providers = {
    vagrant    = vagrant
    ssh        = ssh
    docker     = docker
    grafana    = grafana
    postgresql = postgresql
    mysql      = mysql
  }

  vagrantfile_dir = local.vagrantfile_dir
  engines         = local.engines
  stand_ip        = local.stand_ip
  service_prefix  = local.service_prefix

  mysql_port      = local.mysql_port
  docker_tcp_port = local.docker_tcp_port

  mysql_users           = local.mysql_users
  mysql_databases       = local.mysql_databases
  mysql_user_privileges = local.mysql_user_privileges

  mysql_root_password = local.mysql_root_password
  pmm_admin_password  = local.pmm_admin_password
  mysql_tf_password   = local.mysql_tf_password
  pmm_db_password     = local.pmm_db_password
}
