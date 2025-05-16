output "config_role_arn" {
  description = "ARN of the IAM role used by AWS Config"
  value       = module.iam.config_role_arn
}

output "config_rules" {
  description = "List of AWS Config rules created"
  value       = module.config.config_rules
}
