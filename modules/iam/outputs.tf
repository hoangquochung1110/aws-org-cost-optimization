output "config_role_arn" {
  description = "ARN of the IAM role used by AWS Config"
  value       = aws_iam_role.config_role.arn
}

output "config_role_name" {
  description = "Name of the IAM role used by AWS Config"
  value       = aws_iam_role.config_role.name
}

# Add output for the Lambda role ARN
output "ebs_volume_check_function_role_name" {
  value       = aws_iam_role.ebs_volume_check_function_role.name
  description = "ARN of the Lambda IAM role"
}

output "ebs_volume_check_function_role_arn" {
  value       = aws_iam_role.ebs_volume_check_function_role.arn
  description = "ARN of the Lambda IAM role"
}

output "config_remediation_role_arn" {
  value       = aws_iam_role.config_remediation_role.arn
  description = "ARN of the Config remediation role"
}

output "ssm_automation_role_arn" {
  value       = aws_iam_role.ssm_automation_role.arn
  description = "ARN of the SSM automation role"
}