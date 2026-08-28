# =============================================================================
# Провайдеры
# =============================================================================

provider "docker" {
  host = "tcp://${local.stand_ip}:${local.docker_tcp_port}"
}

provider "grafana" {
  url                  = "https://${local.stand_ip}/graph/"
  auth                 = "admin:${local.pmm_admin_password}"
  insecure_skip_verify = true
}

provider "mysql" {
  endpoint = "${local.stand_ip}:${local.mysql_port}"
  username = "tfadmin"
  password = local.mysql_tf_password
}
