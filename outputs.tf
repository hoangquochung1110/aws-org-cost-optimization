output "config_role_arn" {
  description = "ARN of the IAM role used by AWS Config"
  value       = module.iam.config_role_arn
}

output "config_rules" {
  description = "List of AWS Config rules created"
  value       = module.config.config_rules
}

output "config_remediation_role_arn" {
  value       = module.iam.config_remediation_role_arn
  description = "ARN of the Config remediation role"
}

output "ssm_automation_role_arn" {
  value       = module.iam.ssm_automation_role_arn
  description = "ARN of the SSM automation role"
}