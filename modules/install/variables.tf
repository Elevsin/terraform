# =============================================================================
# Модуль: установка пакетов
# =============================================================================

terraform {
  required_providers {
    ssh = {
      source = "loafoe/ssh"
    }
  }
}

variable "ssh" {
  description = "Параметры SSH-подключения к ВМ"
  type = object({
    host        = string
    port        = string
    user        = string
    private_key = string
  })
  sensitive = true
}

variable "install_postgres" {
  description = "Ставить ли PostgreSQL"
  type        = bool
  default     = true
}

variable "install_mysql" {
  description = "Ставить ли Percona Server"
  type        = bool
  default     = true
}

variable "postgres_version" {
  description = "Мажорная версия PostgreSQL"
  type        = string
  default     = "17"
}

variable "percona_repo" {
  description = "Алиас репозитория percona-release для нужной ветки"
  type        = string
  default     = "ps-84-lts"
}

variable "percona_version" {
  description = "Версия percona-server-server."
  type        = string
  default     = "8.4.8-8-1.trixie"
}

variable "mysql_root_password" {
  description = "Пароль root@localhost в Percona Server."
  type        = string
  sensitive   = true
}

variable "docker_tcp_port" {
  description = "Порт, на котором демон Docker будет слушать TCP"
  type        = number
  default     = 2375
}
