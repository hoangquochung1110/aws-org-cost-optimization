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

# AWS Config module
module "config" {
  source = "./modules/config"

  project_name    = var.project_name
  config_role_arn = module.iam.config_role_arn
  config_bucket = var.config_bucket
  tags            = var.tags
}
