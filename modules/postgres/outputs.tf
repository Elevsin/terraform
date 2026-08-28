output "access_check" {
  description = "Фактическое значение listen_addresses"
  value       = ssh_resource.access.result
}

output "pmm_check" {
  description = "Список сервисов PMM после регистрации"
  value       = ssh_resource.pmm_add.result
  sensitive   = true
}

output "databases" {
  description = "Созданные базы и их владельцы"
  value       = { for k, db in postgresql_database.app : k => db.owner }
}
