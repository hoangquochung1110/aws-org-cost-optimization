terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

# IAM module for AWS Config roles and policies
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  tags         = var.tags
}

# Lambda module for EBS volume checking
module "lambda" {
  source = "./modules/lambda"

  lambda_role_arn = module.iam.ebs_volume_check_function_role_arn
  tags            = var.tags
}

# AWS Config module
module "config" {
  source = "./modules/config"

  project_name               = var.project_name
  config_role_arn           = module.iam.config_role_arn
  ssm_automation_role_arn =  module.iam.ssm_automation_role_arn
  config_bucket             = var.config_bucket
  ebs_volume_check_lambda_arn = module.lambda.ebs_volume_check_lambda_arn
  tags                      = var.tags
}
