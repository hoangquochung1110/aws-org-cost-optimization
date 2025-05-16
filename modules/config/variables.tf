variable "project_name" {
  description = "Name of the project, used as prefix for resource names"
  type        = string
}

variable "config_role_arn" {
  description = "ARN of the IAM role for AWS Config"
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