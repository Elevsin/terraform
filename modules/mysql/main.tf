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
    "printf '[mysqld]\\nbind-address = 0.0.0.0\\n' | sudo tee /etc/mysql/conf.d/bind.cnf",
    "sudo systemctl restart mysql",
    "mysql -e \"CREATE USER IF NOT EXISTS 'tfadmin'@'${var.tf_host_mask}' IDENTIFIED BY '${var.tf_password}'; GRANT ALL ON *.* TO 'tfadmin'@'${var.tf_host_mask}' WITH GRANT OPTION;\"",
    "mysql -e \"SELECT @@bind_address\"",
  ]
}

# =============================================================================
# Учётка для мониторинга
# =============================================================================

resource "mysql_user" "pmm" {
  depends_on = [ssh_resource.access]

  user               = "pmm"
  host               = "127.0.0.1"
  plaintext_password = var.pmm_password
}

resource "mysql_grant" "pmm" {
  user       = mysql_user.pmm.user
  host       = mysql_user.pmm.host
  database   = "*"
  table      = "*"
  privileges = ["SELECT", "PROCESS", "REPLICATION CLIENT", "RELOAD", "BACKUP_ADMIN"]
}

# =============================================================================
# Прикладной слой
# =============================================================================

locals {
  users      = { for u in var.users : u.name => u }
  databases  = { for db in var.databases : db.name => db }
  privileges = { for p in var.user_privileges : "${p.database}:${p.user}" => p }

  role_privileges = {
    select = ["SELECT"]
    dml    = ["SELECT", "INSERT", "UPDATE", "DELETE"]
    all    = ["ALL PRIVILEGES"]
  }
}

resource "mysql_user" "app" {
  for_each = local.users

  user               = each.key
  host               = var.app_host_mask
  plaintext_password = sensitive(each.value.password)

  depends_on = [ssh_resource.access]
}

resource "mysql_database" "app" {
  for_each = local.databases

  name                  = each.key
  default_character_set = each.value.charset
  default_collation     = each.value.collation

  depends_on = [ssh_resource.access]
}

resource "mysql_grant" "owner" {
  for_each = local.databases

  user       = mysql_user.app[each.value.owner].user
  host       = mysql_user.app[each.value.owner].host
  database   = mysql_database.app[each.key].name
  table      = "*"
  privileges = ["ALL PRIVILEGES"]
}

resource "mysql_grant" "app" {
  for_each = local.privileges

  user       = mysql_user.app[each.value.user].user
  host       = mysql_user.app[each.value.user].host
  database   = mysql_database.app[each.value.database].name
  table      = "*"
  privileges = local.role_privileges[each.value.role]
}

# =============================================================================
# Регистрация сервиса в PMM
# =============================================================================

resource "ssh_resource" "pmm_add" {
  depends_on = [mysql_grant.pmm]

  host        = var.ssh.host
  port        = var.ssh.port
  user        = var.ssh.user
  private_key = var.ssh.private_key
  timeout     = "5m"

  commands = [
    "sudo pmm-admin remove mysql ${var.service_name} || true",
    "sudo pmm-admin add mysql --username=pmm --password='${var.pmm_password}' --host=127.0.0.1 --port=${var.port} --service-name=${var.service_name} --query-source=perfschema",
    "sudo pmm-admin list",
  ]
}
