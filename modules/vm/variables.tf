# =============================================================================
# Модуль: виртуальная машина
# =============================================================================

terraform {
  required_providers {
    vagrant = {
      source = "bmatcuk/vagrant"
    }
  }
}

variable "vagrantfile_dir" {
  description = "Каталог с Vagrantfile относительно рабочего каталога Terraform. Там же vagrant создаёт .vagrant с метаданными машины"
  type        = string
}

variable "machine_name" {
  description = "Имя машины из Vagrantfile. Нужно для поиска её ssh_config по имени, а не по индексу"
  type        = string
  default     = "default"
}
