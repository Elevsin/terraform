# =============================================================================
# Конфигурация среды STAGE
# =============================================================================

locals {
  engines = ["mysql"]

  stand_ip        = "192.168.56.51"
  vagrantfile_dir = "../../vm/stage"

  service_prefix = "stage"

  mysql_port      = 3306
  docker_tcp_port = 2375

  # ---------------------------------------------------------------------------
  # Прикладной слой
  # ---------------------------------------------------------------------------

  mysql_users = [
    { name = "stage_legacy_owner", password = "StageLegacyOwner123" },
    { name = "stage_qa", password = "StageQa123" },
  ]

  mysql_databases = [
    { name = "legacy", owner = "stage_legacy_owner" },
  ]

  mysql_user_privileges = [
    { user = "stage_qa", database = "legacy", role = "select" },
  ]

  # ---------------------------------------------------------------------------
  # Пароли
  # ---------------------------------------------------------------------------

  mysql_root_password = "StageRoot123"
  pmm_admin_password  = "StagePmmAdmin123"
  mysql_tf_password   = "StageTfAdmin123"
  pmm_db_password     = "StagePmmDb123"
}
