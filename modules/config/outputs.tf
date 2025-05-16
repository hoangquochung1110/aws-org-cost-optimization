output "config_rules" {
  description = "List of AWS Config rules created"
  value = [
    aws_config_config_rule.ec2-ebs-encryption-by-default.id
  ]
}
