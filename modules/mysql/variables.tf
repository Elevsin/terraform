# =============================================================================
# Модуль MySQL (Percona Server): настройка сервера и прикладной слой
# =============================================================================

terraform {
  required_version = "~> 1.16"

  required_providers {
    ssh = {
      source  = "loafoe/ssh"
      version = "~> 2.7"
    }
    mysql = {
      source  = "petoju/mysql"
      version = "~> 3.0.94"
    }
  }
}

variable "ssh" {
  description = "Параметры SSH-подключения к ВМ."
  type = object({
    host        = string
    port        = string
    user        = string
    private_key = string
  })
  sensitive = true
}

variable "port" {
  description = "Порт сервера"
  type        = number
  default     = 3306
}

variable "tf_password" {
  description = "Пароль учётки tfadmin, под которой подключается провайдер."
  type        = string
  sensitive   = true
}

variable "tf_host_mask" {
  description = "Маска хоста для tfadmin, например 192.168.56.%"
  type        = string
}

variable "app_host_mask" {
  description = "Маска хоста для прикладных пользователей."
  type        = string
}

variable "pmm_password" {
  description = "Пароль пользователя pmm, под которым агент собирает метрики"
  type        = string
  sensitive   = true
}

variable "service_name" {
  description = "Имя сервиса в PMM."
  type        = string
  default     = "mysql-local"
}

# -----------------------------------------------------------------------------
# Прикладной слой
# -----------------------------------------------------------------------------

variable "users" {
  description = "Учётные записи. Пользователь в MySQL определяется парой user@host и общий для всего сервера."
  type = list(object({
    name     = string
    password = string
  }))
  default = []

  validation {
    condition     = length(var.users) == length(distinct([for u in var.users : u.name]))
    error_message = "Имена пользователей повторяются."
  }

  validation {
    # 32 символа — предел имени пользователя в MySQL
    condition     = alltrue([for u in var.users : can(regex("^[a-z_][a-z0-9_]{0,31}$", u.name))])
    error_message = "Имя пользователя: строчная латиница, цифры и подчёркивание, до 32 символов, первый символ не цифра."
  }

  validation {
    condition     = alltrue([for u in var.users : can(regex("^[A-Za-z0-9!@#%^&*()_+=-]{8,}$", u.password))])
    error_message = "Пароль: минимум 8 символов, латиница, цифры и !@#%^&*()_+=- . Кавычки, слеши, доллар и пробелы недопустимы."
  }
}

variable "databases" {
  description = "Прикладные базы. owner — имя из списка users."
  type = list(object({
    name      = string
    owner     = string
    charset   = optional(string, "utf8mb4")
    collation = optional(string, "utf8mb4_0900_ai_ci")
  }))
  default = []

  validation {
    condition     = length(var.databases) == length(distinct([for db in var.databases : db.name]))
    error_message = "Имена баз повторяются."
  }

  validation {
    condition     = alltrue([for db in var.databases : can(regex("^[a-z_][a-z0-9_]{0,63}$", db.name))])
    error_message = "Имя базы: строчная латиница, цифры и подчёркивание, до 64 символов, первый символ не цифра."
  }

  validation {
    condition = alltrue([
      for db in var.databases : contains([for u in var.users : u.name], db.owner)
    ])
    error_message = "Владелец базы не найден в списке users."
  }
}

variable "user_privileges" {
  description = "Права пользователей на базы. Один пользователь может иметь разные роли в разных базах"
  type = list(object({
    user     = string
    database = string
    role     = string # select | dml | all
  }))
  default = []

  validation {
    condition     = alltrue([for p in var.user_privileges : contains(["select", "dml", "all"], p.role)])
    error_message = "Допустимые значения role: select, dml, all."
  }

  validation {
    condition = alltrue([
      for p in var.user_privileges : contains([for u in var.users : u.name], p.user)
    ])
    error_message = "В user_privileges указан пользователь, отсутствующий в users."
  }

  validation {
    condition = alltrue([
      for p in var.user_privileges : contains([for db in var.databases : db.name], p.database)
    ])
    error_message = "В user_privileges указана база, отсутствующая в databases."
  }

  validation {
    condition = length(var.user_privileges) == length(distinct([
      for p in var.user_privileges : "${p.database}:${p.user}"
    ]))
    error_message = "Для одной пары пользователь+база указано несколько записей."
  }
}
