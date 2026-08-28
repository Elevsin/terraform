output "vm_ssh" {
  description = "Строка подключения к ВМ через проброшенный порт NAT"
  value       = module.vm.connection_string
  sensitive   = true
}

output "postgres_check" {
  description = "Версия работающего сервера PostgreSQL"
  value       = module.install.postgres_check
}

output "mysql_check" {
  description = "Версия работающего сервера Percona"
  value       = module.install.mysql_check
  sensitive   = true
}

output "docker_check" {
  description = "Версия Docker Engine"
  value       = module.install.docker_check
}

output "pmm_url" {
  description = "Адрес интерфейса PMM."
  value       = module.pmm.url
}

output "pmm_client_check" {
  description = "Вывод pmm-admin status: подключение агента к серверу"
  value       = module.pmm.client_check
  sensitive   = true
}

output "pg_access_check" {
  description = "Фактическое значение listen_addresses"
  value       = one(module.postgres[*].access_check)
}

output "mysql_access_check" {
  description = "Фактическое значение bind_address"
  value       = one(module.mysql[*].access_check)
  sensitive   = true
}

output "pg_pmm_check" {
  description = "Список сервисов PMM после регистрации PostgreSQL"
  value       = one(module.postgres[*].pmm_check)
  sensitive   = true
}

output "mysql_pmm_check" {
  description = "Список сервисов PMM после регистрации MySQL"
  value       = one(module.mysql[*].pmm_check)
  sensitive   = true
}

output "pg_databases" {
  description = "Созданные базы PostgreSQL и их владельцы"
  value       = one(module.postgres[*].databases)
}

output "mysql_databases" {
  description = "Созданные базы MySQL и их владельцы"
  value       = one(module.mysql[*].databases)
}
