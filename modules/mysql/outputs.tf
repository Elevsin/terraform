output "access_check" {
  description = "Фактическое значение bind_address"
  value       = ssh_resource.access.result
  sensitive   = true
}

output "pmm_check" {
  description = "Список сервисов PMM после регистрации"
  value       = ssh_resource.pmm_add.result
  sensitive   = true
}

output "databases" {
  description = "Созданные базы и их владельцы"
  value       = { for k, db in local.databases : k => db.owner }
}
