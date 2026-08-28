output "client_check" {
  description = "Вывод pmm-admin status: подключение агента к серверу"
  value       = ssh_resource.client.result
  sensitive   = true
}

output "url" {
  description = "Адрес интерфейса PMM"
  value       = "https://${var.stand_ip}"
}
