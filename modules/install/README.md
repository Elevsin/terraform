<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.16 |
| <a name="requirement_ssh"></a> [ssh](#requirement\_ssh) | ~> 2.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ssh"></a> [ssh](#provider\_ssh) | ~> 2.7 |

## Resources

| Name | Type |
|------|------|
| [ssh_resource.docker](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |
| [ssh_resource.mysql](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |
| [ssh_resource.percona_repo](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |
| [ssh_resource.postgres](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_mysql_root_password"></a> [mysql\_root\_password](#input\_mysql\_root\_password) | Пароль root@localhost в Percona Server. | `string` | n/a | yes |
| <a name="input_ssh"></a> [ssh](#input\_ssh) | Параметры SSH-подключения к ВМ | <pre>object({<br/>    host        = string<br/>    port        = string<br/>    user        = string<br/>    private_key = string<br/>  })</pre> | n/a | yes |
| <a name="input_docker_tcp_port"></a> [docker\_tcp\_port](#input\_docker\_tcp\_port) | Порт, на котором демон Docker будет слушать TCP | `number` | `2375` | no |
| <a name="input_install_mysql"></a> [install\_mysql](#input\_install\_mysql) | Ставить ли Percona Server | `bool` | `true` | no |
| <a name="input_install_postgres"></a> [install\_postgres](#input\_install\_postgres) | Ставить ли PostgreSQL | `bool` | `true` | no |
| <a name="input_percona_repo"></a> [percona\_repo](#input\_percona\_repo) | Алиас репозитория percona-release для нужной ветки | `string` | `"ps-84-lts"` | no |
| <a name="input_percona_version"></a> [percona\_version](#input\_percona\_version) | Версия percona-server-server. | `string` | `"8.4.8-8-1.trixie"` | no |
| <a name="input_postgres_version"></a> [postgres\_version](#input\_postgres\_version) | Мажорная версия PostgreSQL | `string` | `"17"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_docker_check"></a> [docker\_check](#output\_docker\_check) | Версия Docker Engine |
| <a name="output_mysql_check"></a> [mysql\_check](#output\_mysql\_check) | Версия работающего сервера Percona |
| <a name="output_postgres_check"></a> [postgres\_check](#output\_postgres\_check) | Версия работающего сервера PostgreSQL |
<!-- END_TF_DOCS -->
