## subnet_group_name should be pre-created
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_elasticache_cluster.redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_cluster) | resource |
| [aws_security_group.redis_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_engine"></a> [engine](#input\_engine) | n/a | `string` | `"redis"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | n/a | `string` | `"7.0"` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `"develop"` | no |
| <a name="input_node_type"></a> [node\_type](#input\_node\_type) | n/a | `string` | `"cache.m4.large"` | no |
| <a name="input_num_cache_nodes"></a> [num\_cache\_nodes](#input\_num\_cache\_nodes) | n/a | `number` | `1` | no |
| <a name="input_parameter_group_name"></a> [parameter\_group\_name](#input\_parameter\_group\_name) | n/a | `string` | `"default.redis7"` | no |
| <a name="input_port"></a> [port](#input\_port) | n/a | `number` | `6379` | no |
| <a name="input_redis_ingress_ports"></a> [redis\_ingress\_ports](#input\_redis\_ingress\_ports) | List of ports opened from Private Subnets CIDR to Redis Instance | `list(number)` | <pre>[<br>  6379<br>]</pre> | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | default sg us-east-1 | `string` | `"sg-0654c85d379f6def2"` | no |
| <a name="input_subnet_group_name"></a> [subnet\_group\_name](#input\_subnet\_group\_name) | should be pre-created | `any` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | default vpc us-east-1 | `string` | `"vpc-0f5e6ce17bb4dd77d"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_redis_dns_name"></a> [redis\_dns\_name](#output\_redis\_dns\_name) | n/a |
| <a name="output_redis_port"></a> [redis\_port](#output\_redis\_port) | n/a |
