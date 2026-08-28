output "ssh" {
  description = "Параметры SSH-подключения."
  value = {
    host        = local.raw.host
    port        = local.raw.port
    user        = local.raw.user
    private_key = local.raw.private_key
  }
  sensitive = true
}

output "connection_string" {
  description = "Строка подключения к ВМ через проброшенный порт NAT"
  value       = "${local.raw.user}@${local.raw.host}:${local.raw.port}"
  sensitive   = true
}
