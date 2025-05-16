data "aws_ssm_parameter" "cluster2_ca" {
  name = "/eks/cluster2/ca"
}
