<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.16 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | ~> 1.26 |
| <a name="requirement_ssh"></a> [ssh](#requirement\_ssh) | ~> 2.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_postgresql"></a> [postgresql](#provider\_postgresql) | ~> 1.26 |
| <a name="provider_ssh"></a> [ssh](#provider\_ssh) | ~> 2.7 |

## Resources

| Name | Type |
|------|------|
| [postgresql_database.app](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/database) | resource |
| [postgresql_default_privileges.tables](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/default_privileges) | resource |
| [postgresql_extension.app_pgss](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/extension) | resource |
| [postgresql_extension.pg_stat_statements](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/extension) | resource |
| [postgresql_grant.connect](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_grant.schema](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_grant.tables](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_role.app](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/role) | resource |
| [postgresql_role.pmm](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/role) | resource |
| [ssh_resource.access](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |
| [ssh_resource.pmm_add](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidr"></a> [allowed\_cidr](#input\_allowed\_cidr) | Подсеть, из которой разрешено подключаться. Дописывается в pg\_hba.conf | `string` | n/a | yes |
| <a name="input_conf_dir"></a> [conf\_dir](#input\_conf\_dir) | Каталог конфигов PostgreSQL на ВМ | `string` | n/a | yes |
| <a name="input_pmm_password"></a> [pmm\_password](#input\_pmm\_password) | Пароль роли pmm, под которой агент собирает метрики | `string` | n/a | yes |
| <a name="input_ssh"></a> [ssh](#input\_ssh) | Параметры SSH-подключения к ВМ | <pre>object({<br/>    host        = string<br/>    port        = string<br/>    user        = string<br/>    private_key = string<br/>  })</pre> | n/a | yes |
| <a name="input_superuser_password"></a> [superuser\_password](#input\_superuser\_password) | Пароль, который будет установлен пользователю postgres | `string` | n/a | yes |
| <a name="input_databases"></a> [databases](#input\_databases) | Прикладные базы. | <pre>list(object({<br/>    name     = string<br/>    owner    = string<br/>    encoding = optional(string, "UTF8")<br/>  }))</pre> | `[]` | no |
| <a name="input_port"></a> [port](#input\_port) | Порт сервера | `number` | `5432` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Имя сервиса в PMM | `string` | `"pg-local"` | no |
| <a name="input_user_privileges"></a> [user\_privileges](#input\_user\_privileges) | Права пользователей на базы. Один пользователь может иметь разные роли в разных базах | <pre>list(object({<br/>    user     = string<br/>    database = string<br/>    role     = string # select | dml | all<br/>  }))</pre> | `[]` | no |
| <a name="input_users"></a> [users](#input\_users) | Учётные записи. | <pre>list(object({<br/>    name     = string<br/>    password = string<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_check"></a> [access\_check](#output\_access\_check) | Фактическое значение listen\_addresses |
| <a name="output_databases"></a> [databases](#output\_databases) | Созданные базы и их владельцы |
| <a name="output_pmm_check"></a> [pmm\_check](#output\_pmm\_check) | Список сервисов PMM после регистрации |
<!-- END_TF_DOCS -->
