# =============================================================================
# Модуль: виртуальная машина
# =============================================================================

terraform {
  required_version = "~> 1.16"

  required_providers {
    vagrant = {
      source  = "bmatcuk/vagrant"
      version = "~> 4.1"
    }
  }
}

variable "vagrantfile_dir" {
  description = "Каталог с Vagrantfile относительно рабочего каталога Terraform. Там же vagrant создаёт .vagrant с метаданными машины"
  type        = string
}
