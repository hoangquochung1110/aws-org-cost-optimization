variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "config_role_arn" {
  description = "ARN of the IAM role for AWS Config"
  type        = string
}

variable "ssm_automation_role_arn" {
  description = "ARN of the IAM role to performs the actual resource modification"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "config_bucket" {
  description = "Name of the S3 bucket for AWS Config"
  type        = string
}

variable "ebs_volume_check_lambda_arn" {
  description = "ARN of the Lambda function that checks EBS volume types"
  type        = string
}