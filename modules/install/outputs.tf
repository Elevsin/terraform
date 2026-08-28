output "postgres_check" {
  description = "Версия работающего сервера PostgreSQL"
  value       = one(ssh_resource.postgres[*].result)
}

output "mysql_check" {
  description = "Версия работающего сервера Percona"
  value       = one(ssh_resource.mysql[*].result)
  sensitive   = true
}

output "docker_check" {
  description = "Версия Docker Engine"
  value       = ssh_resource.docker.result
}
