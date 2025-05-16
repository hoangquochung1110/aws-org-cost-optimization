# AWS Config Rules Demo with Terraform

This project demonstrates how to provision AWS Config resources using Terraform. It sets up AWS Config to monitor your AWS resources for compliance with security best practices.

## Resources Provisioned

- AWS Config Configuration Recorder with continuous recording
- AWS Config Delivery Channel with S3 bucket integration
- Custom Lambda function for EBS volume type checking
- IAM roles with least privilege permissions
- Automated remediation using AWS Systems Manager Automation

## AWS Config Rules Included

1. **EBS Volume Type Optimization** - Checks for EBS gp2 volumes and automatically remediates by converting them to gp3 volumes using AWS Systems Manager Automation
2. **EBS Volume Encryption** - Checks if EBS volumes are encrypted using AWS managed Config rule (EC2_EBS_ENCRYPTION_BY_DEFAULT)

## Components

- Custom Lambda function for EBS volume type checking
- AWS Config Configuration Recorder with continuous monitoring
- AWS Config Delivery Channel for storing configuration changes
- S3 Bucket for storing AWS Config findings
- IAM Roles:
  - Config Role for AWS Config service
  - Lambda Function Role for EBS volume checking
  - Config Remediation Role for triggering remediations
  - SSM Automation Role for performing volume modifications

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.2.0 or newer)
- AWS CLI configured with appropriate credentials
- Sufficient permissions to create the resources defined in this project

## Usage

1. Initialize the Terraform configuration:

```bash
terraform init
```

2. Review the planned changes:

```bash
terraform plan
```

3. Apply the configuration:

```bash
terraform apply
```

4. To destroy the resources when no longer needed:

```bash
terraform destroy
```

## Customization

You can customize this project by:

- Modifying `variables.tf` to change default values like AWS region and project name
- Adding more AWS Config rules in the `config` module
- Extending the Lambda function capabilities in `functions/ebs_volume_check`
- Adjusting IAM permissions in the `iam` module

## Security Considerations

- The S3 bucket is configured with encryption and public access blocking
- IAM roles follow the principle of least privilege
- AWS Config is set up to record all supported resource types
- Custom remediation actions are controlled through specific IAM roles
- Lambda function has minimal required permissions

## License

This project is licensed under the MIT License - see the LICENSE file for details.
