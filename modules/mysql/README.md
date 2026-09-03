<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.16 |
| <a name="requirement_mysql"></a> [mysql](#requirement\_mysql) | ~> 3.0.94 |
| <a name="requirement_ssh"></a> [ssh](#requirement\_ssh) | ~> 2.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_mysql"></a> [mysql](#provider\_mysql) | ~> 3.0.94 |
| <a name="provider_ssh"></a> [ssh](#provider\_ssh) | ~> 2.7 |

## Resources

| Name | Type |
|------|------|
| [mysql_database.app](https://registry.terraform.io/providers/petoju/mysql/latest/docs/resources/database) | resource |
| [mysql_grant.app](https://registry.terraform.io/providers/petoju/mysql/latest/docs/resources/grant) | resource |
| [mysql_grant.owner](https://registry.terraform.io/providers/petoju/mysql/latest/docs/resources/grant) | resource |
| [mysql_grant.pmm](https://registry.terraform.io/providers/petoju/mysql/latest/docs/resources/grant) | resource |
| [mysql_user.app](https://registry.terraform.io/providers/petoju/mysql/latest/docs/resources/user) | resource |
| [mysql_user.pmm](https://registry.terraform.io/providers/petoju/mysql/latest/docs/resources/user) | resource |
| [ssh_resource.access](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |
| [ssh_resource.pmm_add](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_host_mask"></a> [app\_host\_mask](#input\_app\_host\_mask) | Маска хоста для прикладных пользователей. | `string` | n/a | yes |
| <a name="input_pmm_password"></a> [pmm\_password](#input\_pmm\_password) | Пароль пользователя pmm, под которым агент собирает метрики | `string` | n/a | yes |
| <a name="input_ssh"></a> [ssh](#input\_ssh) | Параметры SSH-подключения к ВМ. | <pre>object({<br/>    host        = string<br/>    port        = string<br/>    user        = string<br/>    private_key = string<br/>  })</pre> | n/a | yes |
| <a name="input_tf_host_mask"></a> [tf\_host\_mask](#input\_tf\_host\_mask) | Маска хоста для tfadmin, например 192.168.56.% | `string` | n/a | yes |
| <a name="input_tf_password"></a> [tf\_password](#input\_tf\_password) | Пароль учётки tfadmin, под которой подключается провайдер. | `string` | n/a | yes |
| <a name="input_databases"></a> [databases](#input\_databases) | Прикладные базы. owner — имя из списка users. | <pre>list(object({<br/>    name      = string<br/>    owner     = string<br/>    charset   = optional(string, "utf8mb4")<br/>    collation = optional(string, "utf8mb4_0900_ai_ci")<br/>  }))</pre> | `[]` | no |
| <a name="input_port"></a> [port](#input\_port) | Порт сервера | `number` | `3306` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Имя сервиса в PMM. | `string` | `"mysql-local"` | no |
| <a name="input_user_privileges"></a> [user\_privileges](#input\_user\_privileges) | Права пользователей на базы. Один пользователь может иметь разные роли в разных базах | <pre>list(object({<br/>    user     = string<br/>    database = string<br/>    role     = string # select | dml | all<br/>  }))</pre> | `[]` | no |
| <a name="input_users"></a> [users](#input\_users) | Учётные записи. Пользователь в MySQL определяется парой user@host и общий для всего сервера. | <pre>list(object({<br/>    name     = string<br/>    password = string<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_check"></a> [access\_check](#output\_access\_check) | Фактическое значение bind\_address |
| <a name="output_databases"></a> [databases](#output\_databases) | Созданные базы и их владельцы |
| <a name="output_pmm_check"></a> [pmm\_check](#output\_pmm\_check) | Список сервисов PMM после регистрации |
<!-- END_TF_DOCS -->
