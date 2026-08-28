# =============================================================================
# Модуль: PMM Server и PMM Client
#
# Синглтон — один сервер и один агент на узел, независимо от числа СУБД.
# Модули СУБД только регистрируют у этого агента свои сервисы
# =============================================================================

terraform {
  required_providers {
    ssh = {
      source = "loafoe/ssh"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
    grafana = {
      source = "grafana/grafana"
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

variable "stand_ip" {
  description = "Host-only адрес ВМ. По нему агент обращается к серверу PMM"
  type        = string
}

variable "server_version" {
  description = "Версия PMM Server — тег образа"
  type        = string
}

variable "client_version" {
  description = "Версия пакета pmm-client вместе с номером сборки Debian"
  type        = string
}

variable "admin_password" {
  description = "Пароль admin в PMM Server."
  type        = string
  sensitive   = true
}

variable "wait_timeout" {
  description = "Сколько ждать статуса healthy."
  type        = number
  default     = 300
}
