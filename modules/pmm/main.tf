resource "docker_image" "pmm_server" {
  name         = "percona/pmm-server:${var.server_version}"
  keep_locally = true # не удалять образ при destroy — экономит ~800 МБ загрузки
}

resource "docker_volume" "pmm_data" {
  name = "pmm-data"
}

resource "docker_container" "pmm_server" {
  name    = "pmm-server"
  image   = docker_image.pmm_server.image_id
  restart = "always"

  wait         = true
  wait_timeout = var.wait_timeout

  ports {
    internal = 8443 # в PMM 3 внутренние порты сменились с 443/80 на 8443/8080
    external = 443
  }

  volumes {
    volume_name    = docker_volume.pmm_data.name
    container_path = "/srv" # PMM ожидает данные строго здесь, иначе потеря при обновлении
  }

  env = ["GF_SECURITY_ADMIN_PASSWORD=${var.admin_password}"]
}

# =============================================================================
# Сервисный токен
#
# =============================================================================

resource "grafana_service_account" "pmm_agent" {
  depends_on = [docker_container.pmm_server]
  name       = "pmm-client-agent"
  role       = "Admin" # требуется агенту для регистрации сервисов
}

resource "grafana_service_account_token" "pmm_agent" {
  name               = "pmm-client-token"
  service_account_id = grafana_service_account.pmm_agent.id
}

# =============================================================================
# PMM Client
# =============================================================================

resource "ssh_resource" "client" {
  host        = var.ssh.host
  port        = var.ssh.port
  user        = var.ssh.user
  private_key = var.ssh.private_key
  timeout     = "10m"

  commands = [
    "sudo percona-release enable pmm3-client release",
    "sudo apt-get update -y",
    "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y pmm-client=${var.client_version}",
    "sudo pmm-admin config --server-insecure-tls --server-url=https://service_token:${grafana_service_account_token.pmm_agent.key}@${var.stand_ip}:443",
    "sudo pmm-admin status",
  ]
}
