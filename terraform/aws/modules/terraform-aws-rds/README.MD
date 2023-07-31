## KMS key should be pre-created
## DB subnet group should be pre-created
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.rds_sql_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_security_group.rdssql_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_windows_retention_maintenance"></a> [backup\_windows\_retention\_maintenance](#input\_backup\_windows\_retention\_maintenance) | Backup window time, desired retention in days, maitenance windows | `list(any)` | <pre>[<br>  "03:00-06:00",<br>  "35",<br>  "Mon:00:00-Mon:03:00"<br>]</pre> | no |
| <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name) | Name for the DB subnet group | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Amazon RDS DB Instance class | `string` | `"db.t3.medium"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Should be pre-created | `any` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `"develop"` | no |
| <a name="input_rdssql_engine"></a> [rdssql\_engine](#input\_rdssql\_engine) | SQL Server Version | `string` | `"sqlserver-web"` | no |
| <a name="input_rdssql_engine_version"></a> [rdssql\_engine\_version](#input\_rdssql\_engine\_version) | 15.00 = SQL Server 2019 / 14.00 = SQL Server 2017 / 13.00 = SQL Server 2016 / 12.00 = SQL Server 2014 | `string` | `"15.00"` | no |
| <a name="input_rdssql_ingress_ports"></a> [rdssql\_ingress\_ports](#input\_rdssql\_ingress\_ports) | List of ports opened from Private Subnets CIDR to RDS SQL Instance | `list(number)` | <pre>[<br>  1433<br>]</pre> | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | default sg us-east-1 | `string` | `"sg-0654c85d379f6def2"` | no |
| <a name="input_sql_collation"></a> [sql\_collation](#input\_sql\_collation) | SQL Server Collation | `string` | `"SQL_Latin1_General_CP1_CI_AS"` | no |
| <a name="input_storage_allocation"></a> [storage\_allocation](#input\_storage\_allocation) | Allocated storage Gb, Max allocated storage Gb | `list(any)` | <pre>[<br>  "20",<br>  "100"<br>]</pre> | no |
| <a name="input_time_zone"></a> [time\_zone](#input\_time\_zone) | Database timezone | `string` | `"GMT Standard Time"` | no |
| <a name="input_user_name"></a> [user\_name](#input\_user\_name) | SQL Server Admin username | `string` | `"admin"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | default vpc us-east-1 | `string` | `"vpc-0f5e6ce17bb4dd77d"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | n/a |
| <a name="output_password"></a> [password](#output\_password) | n/a |
