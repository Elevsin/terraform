# =============================================================================
# Модуль stand: стенд целиком
# =============================================================================

terraform {
  required_providers {
    vagrant    = { source = "bmatcuk/vagrant" }
    ssh        = { source = "loafoe/ssh" }
    docker     = { source = "kreuzwerker/docker" }
    grafana    = { source = "grafana/grafana" }
    postgresql = { source = "cyrilgdn/postgresql" }
    mysql      = { source = "petoju/mysql" }
  }
}

variable "vagrantfile_dir" {
  description = "Каталог с Vagrantfile относительно каталога среды"
  type        = string
}

variable "machine_name" {
  description = "Имя машины из Vagrantfile"
  type        = string
  default     = "default"
}

variable "engines" {
  description = "Какие СУБД ставить в этой среде"
  type        = list(string)

  validation {
    condition     = alltrue([for e in var.engines : contains(["postgres", "mysql"], e)])
    error_message = "Допустимые значения: postgres, mysql."
  }

  validation {
    condition     = length(var.engines) > 0
    error_message = "Список engines пуст. Укажите хотя бы одну СУБД."
  }

  validation {
    condition     = length(var.engines) == length(distinct(var.engines))
    error_message = "В списке engines есть повторы."
  }
}

variable "stand_ip" {
  description = "Host-only адрес ВМ. Должен совпадать с адресом в Vagrantfile этой среды"
  type        = string

  validation {
    condition     = can(cidrnetmask("${var.stand_ip}/32"))
    error_message = "Ожидается корректный адрес IPv4."
  }

  validation {
    condition = can(cidrnetmask("${var.stand_ip}/32")) ? (
      tonumber(element(split(".", var.stand_ip), 3)) > 0 &&
      tonumber(element(split(".", var.stand_ip), 3)) < 255
    ) : true
    error_message = "Последний октет не может быть 0 или 255."
  }
}

variable "service_prefix" {
  description = "Префикс имён сервисов в PMM."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.service_prefix))
    error_message = "Префикс: строчная латиница, цифры и дефис, первый символ буква."
  }
}

# -----------------------------------------------------------------------------
# Версии и порты
# -----------------------------------------------------------------------------

variable "postgres_version" {
  description = "Мажорная версия PostgreSQL — она же суффикс пакета и путь к конфигам"
  type        = string
  default     = "17"

  validation {
    condition     = can(regex("^[0-9]{2}$", var.postgres_version))
    error_message = "Ожидается номер мажорной версии из двух цифр, например 17."
  }
}

variable "postgres_port" {
  description = "Порт PostgreSQL"
  type        = number
  default     = 5432

  validation {
    condition     = var.postgres_port > 1024 && var.postgres_port < 65536
    error_message = "Порт должен быть в диапазоне 1025–65535."
  }
}

variable "percona_repo" {
  description = "Алиас репозитория percona-release"
  type        = string
  default     = "ps-84-lts"

  validation {
    condition     = can(regex("^[a-z0-9.-]+$", var.percona_repo))
    error_message = "Алиас репозитория: строчные латинские буквы, цифры, точка и дефис."
  }
}

variable "percona_version" {
  description = "Версия percona-server-server вместе с номером сборки и кодовым именем дистрибутива"
  type        = string
  default     = "8.4.8-8-1.trixie"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+-[0-9]+-[0-9]+\\.[a-z]+$", var.percona_version))
    error_message = "Ожидается формат вида 8.4.8-8-1.trixie."
  }
}

variable "mysql_port" {
  description = "Порт MySQL"
  type        = number
  default     = 3306

  validation {
    condition     = var.mysql_port > 1024 && var.mysql_port < 65536
    error_message = "Порт должен быть в диапазоне 1025–65535."
  }
}

variable "pmm_version" {
  description = "Версия PMM Server — тег образа"
  type        = string
  default     = "3.9.0"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.pmm_version))
    error_message = "Ожидается версия из трёх чисел. Плавающие теги вроде 3 или latest не допускаются."
  }
}

variable "pmm_client_version" {
  description = "Версия пакета pmm-client вместе с номером сборки"
  type        = string
  default     = "3.9.0-1.trixie"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+-[0-9]+\\.[a-z]+$", var.pmm_client_version))
    error_message = "Ожидается формат вида 3.9.0-1.trixie."
  }

  validation {
    condition     = split("-", var.pmm_client_version)[0] == var.pmm_version
    error_message = "Версии PMM Server и PMM Client должны совпадать: клиент новее сервера не поддерживается."
  }
}

variable "docker_tcp_port" {
  description = "Порт демона Docker"
  type        = number
  default     = 2375

  validation {
    condition     = var.docker_tcp_port > 1024 && var.docker_tcp_port < 65536
    error_message = "Порт должен быть в диапазоне 1025–65535."
  }

  validation {
    condition     = !contains([var.postgres_port, var.mysql_port, 443], var.docker_tcp_port)
    error_message = "Порт Docker занят PostgreSQL, MySQL или PMM Server."
  }
}

# -----------------------------------------------------------------------------
# Прикладной слой
#
# Три списка на каждую СУБД: users, databases и user_privileges.
# -----------------------------------------------------------------------------

variable "pg_users" {
  description = "Учётные записи PostgreSQL"
  type = list(object({
    name     = string
    password = string
  }))
  default = []
}

variable "pg_databases" {
  description = "Базы PostgreSQL. owner — имя из pg_users"
  type = list(object({
    name     = string
    owner    = string
    encoding = optional(string, "UTF8")
  }))
  default = []
}

variable "pg_user_privileges" {
  description = "Права пользователей PostgreSQL на базы. role: select, dml или all"
  type = list(object({
    user     = string
    database = string
    role     = string
  }))
  default = []
}

variable "mysql_users" {
  description = "Учётные записи MySQL"
  type = list(object({
    name     = string
    password = string
  }))
  default = []
}

variable "mysql_databases" {
  description = "Базы MySQL. owner — имя из mysql_users"
  type = list(object({
    name      = string
    owner     = string
    charset   = optional(string, "utf8mb4")
    collation = optional(string, "utf8mb4_0900_ai_ci")
  }))
  default = []
}

variable "mysql_user_privileges" {
  description = "Права пользователей MySQL на базы. role: select, dml или all"
  type = list(object({
    user     = string
    database = string
    role     = string
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Пароли
# -----------------------------------------------------------------------------

variable "mysql_root_password" {
  description = "Пароль root@localhost в Percona Server"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[A-Za-z0-9!@#%^&*()_+=-]{8,}$", var.mysql_root_password))
    error_message = "Пароль: минимум 8 символов, латиница, цифры и !@#%^&*()_+=- . Кавычки, слеши, доллар, пробелы недопустимы."
  }
}

variable "pmm_admin_password" {
  description = "Пароль admin в PMM Server."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[A-Za-z0-9!@#%^&*()_+=-]{8,}$", var.pmm_admin_password))
    error_message = "Пароль: минимум 8 символов, латиница, цифры и !@#%^&*()_+=- . Кавычки, слеши, доллар, пробелы недопустимы."
  }
}

variable "postgres_password" {
  description = "Пароль суперпользователя postgres"
  type        = string
  sensitive   = true
  default     = ""

  validation {
    condition     = contains(var.engines, "postgres") ? can(regex("^[A-Za-z0-9!@#%^&*()_+=-]{8,}$", var.postgres_password)) : true
    error_message = "Пароль: минимум 8 символов, латиница, цифры и !@#%^&*()_+=- . Кавычки, слеши, доллар, пробелы недопустимы."
  }
}

variable "mysql_tf_password" {
  description = "Пароль учётки tfadmin, под которой подключается провайдер mysql"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[A-Za-z0-9!@#%^&*()_+=-]{8,}$", var.mysql_tf_password))
    error_message = "Пароль: минимум 8 символов, латиница, цифры и !@#%^&*()_+=- . Кавычки, слеши, доллар, пробелы недопустимы."
  }
}

variable "pmm_db_password" {
  description = "Пароль пользователя pmm в обеих СУБД"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[A-Za-z0-9!@#%^&*()_+=-]{8,}$", var.pmm_db_password))
    error_message = "Пароль: минимум 8 символов, латиница, цифры и !@#%^&*()_+=- . Кавычки, слеши, доллар, пробелы недопустимы."
  }
}
