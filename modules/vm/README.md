<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.16 |
| <a name="requirement_vagrant"></a> [vagrant](#requirement\_vagrant) | ~> 4.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_vagrant"></a> [vagrant](#provider\_vagrant) | 4.1.0 |

## Resources

| Name | Type |
|------|------|
| [vagrant_vm.this](https://registry.terraform.io/providers/bmatcuk/vagrant/latest/docs/resources/vm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vagrantfile_dir"></a> [vagrantfile\_dir](#input\_vagrantfile\_dir) | Каталог с Vagrantfile относительно рабочего каталога Terraform. Там же vagrant создаёт .vagrant с метаданными машины | `string` | n/a | yes |
| <a name="input_machine_name"></a> [machine\_name](#input\_machine\_name) | Имя машины из Vagrantfile. Нужно для поиска её ssh\_config по имени, а не по индексу | `string` | `"default"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connection_string"></a> [connection\_string](#output\_connection\_string) | Строка подключения к ВМ через проброшенный порт NAT |
| <a name="output_ssh"></a> [ssh](#output\_ssh) | Параметры SSH-подключения. |
<!-- END_TF_DOCS -->
