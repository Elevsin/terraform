<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.16 |
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | ~> 4.5 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | ~> 3.25.7 |
| <a name="requirement_ssh"></a> [ssh](#requirement\_ssh) | ~> 2.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_docker"></a> [docker](#provider\_docker) | 4.6.0 |
| <a name="provider_grafana"></a> [grafana](#provider\_grafana) | 3.25.9 |
| <a name="provider_ssh"></a> [ssh](#provider\_ssh) | 2.7.0 |

## Resources

| Name | Type |
|------|------|
| [docker_container.pmm_server](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container) | resource |
| [docker_image.pmm_server](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image) | resource |
| [docker_volume.pmm_data](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume) | resource |
| [grafana_service_account.pmm_agent](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/service_account) | resource |
| [grafana_service_account_token.pmm_agent](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/service_account_token) | resource |
| [ssh_resource.client](https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Пароль admin в PMM Server. | `string` | n/a | yes |
| <a name="input_client_version"></a> [client\_version](#input\_client\_version) | Версия пакета pmm-client вместе с номером сборки Debian | `string` | n/a | yes |
| <a name="input_server_version"></a> [server\_version](#input\_server\_version) | Версия PMM Server — тег образа | `string` | n/a | yes |
| <a name="input_ssh"></a> [ssh](#input\_ssh) | Параметры SSH-подключения к ВМ | <pre>object({<br/>    host        = string<br/>    port        = string<br/>    user        = string<br/>    private_key = string<br/>  })</pre> | n/a | yes |
| <a name="input_stand_ip"></a> [stand\_ip](#input\_stand\_ip) | Host-only адрес ВМ. По нему агент обращается к серверу PMM | `string` | n/a | yes |
| <a name="input_wait_timeout"></a> [wait\_timeout](#input\_wait\_timeout) | Сколько ждать статуса healthy. | `number` | `300` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_check"></a> [client\_check](#output\_client\_check) | Вывод pmm-admin status: подключение агента к серверу |
| <a name="output_url"></a> [url](#output\_url) | Адрес интерфейса PMM |
<!-- END_TF_DOCS -->
