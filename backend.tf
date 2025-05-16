# This file contains the backend configuration
# Uncomment and configure as needed for your environment

# For local development (default)
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# For team environments, consider using a remote backend
# Example with S3 (uncomment and configure as needed):
# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "aws-config-rules-demo/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }
