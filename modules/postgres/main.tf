# =============================================================================
# Доступ к серверу из host-only сети
# =============================================================================

resource "ssh_resource" "access" {
  host        = var.ssh.host
  port        = var.ssh.port
  user        = var.ssh.user
  private_key = var.ssh.private_key
  timeout     = "5m"

  commands = [
    "echo \"listen_addresses = '*'\" | sudo tee ${var.conf_dir}/conf.d/listen.conf",
    "echo \"shared_preload_libraries = 'pg_stat_statements'\" | sudo tee ${var.conf_dir}/conf.d/pgss.conf",
    "grep -q '${var.allowed_cidr}' ${var.conf_dir}/pg_hba.conf || echo 'host all all ${var.allowed_cidr} scram-sha-256' | sudo tee -a ${var.conf_dir}/pg_hba.conf",
    "sudo -u postgres psql -c \"ALTER USER postgres PASSWORD '${var.superuser_password}'\"",
    "sudo systemctl restart postgresql",
    "sudo -u postgres psql -tAc 'SHOW listen_addresses'",
  ]
}

# =============================================================================
# Учётка для мониторинга
# =============================================================================

resource "postgresql_role" "pmm" {
  depends_on = [ssh_resource.access]

  name     = "pmm"
  login    = true
  password = var.pmm_password
  # pg_monitor — встроенная роль: доступ к статистике без прав суперпользователя
  roles = ["pg_monitor"]
}

resource "postgresql_extension" "pg_stat_statements" {
  depends_on = [ssh_resource.access]

  name     = "pg_stat_statements"
  database = "postgres"
}

# =============================================================================
# Прикладной слой
# =============================================================================

locals {
  users      = { for u in var.users : u.name => u }
  databases  = { for db in var.databases : db.name => db }
  privileges = { for p in var.user_privileges : "${p.database}:${p.user}" => p }

  table_privileges = {
    select = ["SELECT"]
    dml    = ["SELECT", "INSERT", "UPDATE", "DELETE"]
    all    = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "TRIGGER"]
  }
}

resource "postgresql_role" "app" {
  for_each = local.users

  name     = each.key
  login    = true
  password = sensitive(each.value.password)

  depends_on = [ssh_resource.access]
}

resource "postgresql_database" "app" {
  for_each = local.databases

  name  = each.key
  owner = postgresql_role.app[each.value.owner].name

  encoding = each.value.encoding
  template = "template0"
}

resource "postgresql_extension" "app_pgss" {
  for_each = local.databases

  name     = "pg_stat_statements"
  database = postgresql_database.app[each.key].name
}

resource "postgresql_grant" "connect" {
  for_each = local.privileges

  role        = postgresql_role.app[each.value.user].name
  database    = postgresql_database.app[each.value.database].name
  object_type = "database"
  privileges  = ["CONNECT"]
}

resource "postgresql_grant" "schema" {
  for_each = local.privileges

  role        = postgresql_role.app[each.value.user].name
  database    = postgresql_database.app[each.value.database].name
  schema      = "public"
  object_type = "schema"
  privileges  = ["USAGE"]
}

resource "postgresql_grant" "tables" {
  for_each = local.privileges

  role        = postgresql_role.app[each.value.user].name
  database    = postgresql_database.app[each.value.database].name
  schema      = "public"
  object_type = "table"
  privileges  = local.table_privileges[each.value.role]
}

resource "postgresql_default_privileges" "tables" {
  for_each = local.privileges

  role     = postgresql_role.app[each.value.user].name
  database = postgresql_database.app[each.value.database].name
  schema   = "public"
  # owner — тот, от чьего имени будут создаваться таблицы
  owner       = postgresql_role.app[local.databases[each.value.database].owner].name
  object_type = "table"
  privileges  = local.table_privileges[each.value.role]
}

# =============================================================================
# Регистрация сервиса в PMM
#
# Агент один на узел, базы добавляются к нему как отдельные сервисы.
# =============================================================================

resource "ssh_resource" "pmm_add" {
  depends_on = [postgresql_role.pmm, postgresql_extension.pg_stat_statements]

  host        = var.ssh.host
  port        = var.ssh.port
  user        = var.ssh.user
  private_key = var.ssh.private_key
  timeout     = "5m"

  commands = [
    "sudo pmm-admin remove postgresql ${var.service_name} || true",
    "sudo pmm-admin add postgresql --username=pmm --password='${var.pmm_password}' --host=127.0.0.1 --port=${var.port} --service-name=${var.service_name}",
    "sudo pmm-admin list",
  ]
}
