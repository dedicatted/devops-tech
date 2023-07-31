variable "key_secret" {
  default = {
    "key1" = "value1"
    "key2" = "value2"
  }
  type = map(string)
}
variable "kms_key_arn" {
  description = "Should be pre-created"
}
