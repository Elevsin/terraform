# =============================================================================
# Конфигурация среды PROD
# =============================================================================

locals {
  engines = ["postgres", "mysql"]

  stand_ip        = "192.168.56.50"
  vagrantfile_dir = "../../vm/prod"

  service_prefix = "prod"

  postgres_port   = 5432
  mysql_port      = 3306
  docker_tcp_port = 2375

  # ---------------------------------------------------------------------------
  # Прикладной слой
  #
  # role: select — только чтение, dml — чтение и запись, all — полные права
  # на объекты. Пользователь без записи в user_privileges создаётся, но прав
  # ни на одну базу не получает.
  # ---------------------------------------------------------------------------

  pg_users = [
    { name = "prod_shop_owner", password = "ProdShopOwner123" },
    { name = "prod_api", password = "ProdApi123" },
    { name = "prod_bi", password = "ProdBi123" },
  ]

  pg_databases = [
    { name = "shop", owner = "prod_shop_owner" },
    { name = "billing", owner = "prod_shop_owner" },
  ]

  pg_user_privileges = [
    { user = "prod_api", database = "shop", role = "dml" },
    { user = "prod_bi", database = "shop", role = "select" },
    { user = "prod_bi", database = "billing", role = "select" },
  ]

  mysql_users = [
    { name = "prod_legacy_owner", password = "ProdLegacyOwner123" },
  ]

  mysql_databases = [
    { name = "legacy", owner = "prod_legacy_owner" },
  ]

  mysql_user_privileges = []

  # ---------------------------------------------------------------------------
  # Пароли
  # ---------------------------------------------------------------------------

  mysql_root_password = "ProdRoot456"
  pmm_admin_password  = "ProdPmmAdmin123"
  postgres_password   = "ProdPgAdmin123"
  mysql_tf_password   = "ProdTfAdmin123"
  pmm_db_password     = "ProdPmmDb123"
  #metrics_key         = "AKIA3XZQ7FJ2MPLVQK9D"

}
