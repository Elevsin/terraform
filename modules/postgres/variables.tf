# =============================================================================
# Модуль PostgreSQL: настройка сервера и прикладной слой
# =============================================================================

terraform {
  required_providers {
    ssh = {
      source = "loafoe/ssh"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
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

variable "conf_dir" {
  description = "Каталог конфигов PostgreSQL на ВМ"
  type        = string
}

variable "port" {
  description = "Порт сервера"
  type        = number
  default     = 5432
}

variable "allowed_cidr" {
  description = "Подсеть, из которой разрешено подключаться. Дописывается в pg_hba.conf"
  type        = string
}

variable "superuser_password" {
  description = "Пароль, который будет установлен пользователю postgres"
  type        = string
  sensitive   = true
}

variable "pmm_password" {
  description = "Пароль роли pmm, под которой агент собирает метрики"
  type        = string
  sensitive   = true
}

variable "service_name" {
  description = "Имя сервиса в PMM"
  type        = string
  default     = "pg-local"
}

# -----------------------------------------------------------------------------
# Прикладной слой
# -----------------------------------------------------------------------------

variable "users" {
  description = "Учётные записи."
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
    condition     = alltrue([for u in var.users : can(regex("^[a-z_][a-z0-9_]{0,62}$", u.name))])
    error_message = "Имя пользователя: строчная латиница, цифры и подчёркивание, до 63 символов, первый символ не цифра."
  }

  validation {
    condition     = alltrue([for u in var.users : can(regex("^[A-Za-z0-9!@#%^&*()_+=-]{8,}$", u.password))])
    error_message = "Пароль: минимум 8 символов, латиница, цифры и !@#%^&*()_+=- . Кавычки, слеши, доллар и пробелы недопустимы."
  }
}

variable "databases" {
  description = "Прикладные базы."
  type = list(object({
    name     = string
    owner    = string
    encoding = optional(string, "UTF8")
  }))
  default = []

  validation {
    condition     = length(var.databases) == length(distinct([for db in var.databases : db.name]))
    error_message = "Имена баз повторяются."
  }

  validation {
    condition     = alltrue([for db in var.databases : can(regex("^[a-z_][a-z0-9_]{0,62}$", db.name))])
    error_message = "Имя базы: строчная латиница, цифры и подчёркивание, до 63 символов, первый символ не цифра."
  }

  validation {
    # Ссылочная целостность: владелец обязан быть объявлен в users
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
