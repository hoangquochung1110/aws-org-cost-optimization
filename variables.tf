variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Name of the project, used as prefix for resource names"
  type        = string
  default     = "aws-config-demo"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "demo"
    Project     = "AWS Config Rules Demo"
    Terraform   = "true"
  }
}

variable "config_bucket" {
  description = "Name of the S3 bucket for AWS Config"
  type        = string
  default = "config-bucket-16052025"
}