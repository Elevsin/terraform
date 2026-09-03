<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.16 |
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | ~> 4.5 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | ~> 3.25.7 |
| <a name="requirement_mysql"></a> [mysql](#requirement\_mysql) | ~> 3.0.94 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | ~> 1.26 |
| <a name="requirement_ssh"></a> [ssh](#requirement\_ssh) | ~> 2.7 |
| <a name="requirement_vagrant"></a> [vagrant](#requirement\_vagrant) | ~> 4.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_install"></a> [install](#module\_install) | ../install | n/a |
| <a name="module_mysql"></a> [mysql](#module\_mysql) | ../mysql | n/a |
| <a name="module_pmm"></a> [pmm](#module\_pmm) | ../pmm | n/a |
| <a name="module_postgres"></a> [postgres](#module\_postgres) | ../postgres | n/a |
| <a name="module_vm"></a> [vm](#module\_vm) | ../vm | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_engines"></a> [engines](#input\_engines) | Какие СУБД ставить в этой среде | `list(string)` | n/a | yes |
| <a name="input_mysql_root_password"></a> [mysql\_root\_password](#input\_mysql\_root\_password) | Пароль root@localhost в Percona Server | `string` | n/a | yes |
| <a name="input_mysql_tf_password"></a> [mysql\_tf\_password](#input\_mysql\_tf\_password) | Пароль учётки tfadmin, под которой подключается провайдер mysql | `string` | n/a | yes |
| <a name="input_pmm_admin_password"></a> [pmm\_admin\_password](#input\_pmm\_admin\_password) | Пароль admin в PMM Server. | `string` | n/a | yes |
| <a name="input_pmm_db_password"></a> [pmm\_db\_password](#input\_pmm\_db\_password) | Пароль пользователя pmm в обеих СУБД | `string` | n/a | yes |
| <a name="input_service_prefix"></a> [service\_prefix](#input\_service\_prefix) | Префикс имён сервисов в PMM. | `string` | n/a | yes |
| <a name="input_stand_ip"></a> [stand\_ip](#input\_stand\_ip) | Host-only адрес ВМ. Должен совпадать с адресом в Vagrantfile этой среды | `string` | n/a | yes |
| <a name="input_vagrantfile_dir"></a> [vagrantfile\_dir](#input\_vagrantfile\_dir) | Каталог с Vagrantfile относительно каталога среды | `string` | n/a | yes |
| <a name="input_docker_tcp_port"></a> [docker\_tcp\_port](#input\_docker\_tcp\_port) | Порт демона Docker | `number` | `2375` | no |
| <a name="input_machine_name"></a> [machine\_name](#input\_machine\_name) | Имя машины из Vagrantfile | `string` | `"default"` | no |
| <a name="input_mysql_databases"></a> [mysql\_databases](#input\_mysql\_databases) | Базы MySQL. owner — имя из mysql\_users | <pre>list(object({<br/>    name      = string<br/>    owner     = string<br/>    charset   = optional(string, "utf8mb4")<br/>    collation = optional(string, "utf8mb4_0900_ai_ci")<br/>  }))</pre> | `[]` | no |
| <a name="input_mysql_port"></a> [mysql\_port](#input\_mysql\_port) | Порт MySQL | `number` | `3306` | no |
| <a name="input_mysql_user_privileges"></a> [mysql\_user\_privileges](#input\_mysql\_user\_privileges) | Права пользователей MySQL на базы. role: select, dml или all | <pre>list(object({<br/>    user     = string<br/>    database = string<br/>    role     = string<br/>  }))</pre> | `[]` | no |
| <a name="input_mysql_users"></a> [mysql\_users](#input\_mysql\_users) | Учётные записи MySQL | <pre>list(object({<br/>    name     = string<br/>    password = string<br/>  }))</pre> | `[]` | no |
| <a name="input_percona_repo"></a> [percona\_repo](#input\_percona\_repo) | Алиас репозитория percona-release | `string` | `"ps-84-lts"` | no |
| <a name="input_percona_version"></a> [percona\_version](#input\_percona\_version) | Версия percona-server-server вместе с номером сборки и кодовым именем дистрибутива | `string` | `"8.4.8-8-1.trixie"` | no |
| <a name="input_pg_databases"></a> [pg\_databases](#input\_pg\_databases) | Базы PostgreSQL. owner — имя из pg\_users | <pre>list(object({<br/>    name     = string<br/>    owner    = string<br/>    encoding = optional(string, "UTF8")<br/>  }))</pre> | `[]` | no |
| <a name="input_pg_user_privileges"></a> [pg\_user\_privileges](#input\_pg\_user\_privileges) | Права пользователей PostgreSQL на базы. role: select, dml или all | <pre>list(object({<br/>    user     = string<br/>    database = string<br/>    role     = string<br/>  }))</pre> | `[]` | no |
| <a name="input_pg_users"></a> [pg\_users](#input\_pg\_users) | Учётные записи PostgreSQL | <pre>list(object({<br/>    name     = string<br/>    password = string<br/>  }))</pre> | `[]` | no |
| <a name="input_pmm_client_version"></a> [pmm\_client\_version](#input\_pmm\_client\_version) | Версия пакета pmm-client вместе с номером сборки | `string` | `"3.9.0-1.trixie"` | no |
| <a name="input_pmm_version"></a> [pmm\_version](#input\_pmm\_version) | Версия PMM Server — тег образа | `string` | `"3.9.0"` | no |
| <a name="input_postgres_password"></a> [postgres\_password](#input\_postgres\_password) | Пароль суперпользователя postgres | `string` | `""` | no |
| <a name="input_postgres_port"></a> [postgres\_port](#input\_postgres\_port) | Порт PostgreSQL | `number` | `5432` | no |
| <a name="input_postgres_version"></a> [postgres\_version](#input\_postgres\_version) | Мажорная версия PostgreSQL — она же суффикс пакета и путь к конфигам | `string` | `"17"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_docker_check"></a> [docker\_check](#output\_docker\_check) | Версия Docker Engine |
| <a name="output_mysql_access_check"></a> [mysql\_access\_check](#output\_mysql\_access\_check) | Фактическое значение bind\_address |
| <a name="output_mysql_check"></a> [mysql\_check](#output\_mysql\_check) | Версия работающего сервера Percona |
| <a name="output_mysql_databases"></a> [mysql\_databases](#output\_mysql\_databases) | Созданные базы MySQL и их владельцы |
| <a name="output_mysql_pmm_check"></a> [mysql\_pmm\_check](#output\_mysql\_pmm\_check) | Список сервисов PMM после регистрации MySQL |
| <a name="output_pg_access_check"></a> [pg\_access\_check](#output\_pg\_access\_check) | Фактическое значение listen\_addresses |
| <a name="output_pg_databases"></a> [pg\_databases](#output\_pg\_databases) | Созданные базы PostgreSQL и их владельцы |
| <a name="output_pg_pmm_check"></a> [pg\_pmm\_check](#output\_pg\_pmm\_check) | Список сервисов PMM после регистрации PostgreSQL |
| <a name="output_pmm_client_check"></a> [pmm\_client\_check](#output\_pmm\_client\_check) | Вывод pmm-admin status: подключение агента к серверу |
| <a name="output_pmm_url"></a> [pmm\_url](#output\_pmm\_url) | Адрес интерфейса PMM. |
| <a name="output_postgres_check"></a> [postgres\_check](#output\_postgres\_check) | Версия работающего сервера PostgreSQL |
| <a name="output_vm_ssh"></a> [vm\_ssh](#output\_vm\_ssh) | Строка подключения к ВМ через проброшенный порт NAT |
<!-- END_TF_DOCS -->
