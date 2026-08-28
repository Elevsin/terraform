# =============================================================================
# Outputs
# =============================================================================

output "vm_ssh" {
  description = "Строка подключения к ВМ через проброшенный порт NAT"
  value       = module.stand.vm_ssh
  sensitive   = true
}

output "postgres_check" {
  description = "Версия работающего сервера PostgreSQL"
  value       = module.stand.postgres_check
}

output "mysql_check" {
  description = "Версия работающего сервера Percona"
  value       = module.stand.mysql_check
  sensitive   = true
}

output "docker_check" {
  description = "Версия Docker Engine"
  value       = module.stand.docker_check
}

output "pmm_url" {
  description = "Адрес интерфейса PMM. Логин admin, пароль из config.tf"
  value       = module.stand.pmm_url
}

output "pmm_client_check" {
  description = "Вывод pmm-admin status: подключение агента к серверу"
  value       = module.stand.pmm_client_check
  sensitive   = true
}

output "pg_access_check" {
  description = "Фактическое значение listen_addresses"
  value       = module.stand.pg_access_check
}

output "mysql_access_check" {
  description = "Фактическое значение bind_address"
  value       = module.stand.mysql_access_check
  sensitive   = true
}

output "pg_pmm_check" {
  description = "Список сервисов PMM после регистрации PostgreSQL"
  value       = module.stand.pg_pmm_check
  sensitive   = true
}

output "mysql_pmm_check" {
  description = "Список сервисов PMM после регистрации MySQL"
  value       = module.stand.mysql_pmm_check
  sensitive   = true
}

output "pg_databases" {
  description = "Созданные базы PostgreSQL и их владельцы"
  value       = module.stand.pg_databases
}

output "mysql_databases" {
  description = "Созданные базы MySQL и их владельцы"
  value       = module.stand.mysql_databases
}
