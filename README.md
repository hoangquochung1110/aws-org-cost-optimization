# AWS Config Rules Demo with Terraform

This project demonstrates how to provision AWS Config resources using Terraform. It sets up AWS Config to monitor your AWS resources for compliance with security best practices.

## Resources Provisioned

- AWS Config Configuration Recorder
- AWS Config Delivery Channel
- S3 Bucket for storing AWS Config findings
- IAM Role with necessary permissions
- AWS Config Rules for security best practices

## AWS Config Rules Included

1. **EBS Volume Encryption** - Checks if EBS volumes are encrypted
2. **S3 Bucket Public Access** - Ensures S3 buckets do not allow public read access
3. **S3 Bucket Encryption** - Verifies S3 buckets have server-side encryption enabled
4. **Root Account MFA** - Checks if the root account has MFA enabled
5. **IAM User MFA** - Verifies if IAM users have MFA enabled

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

- Modifying `variables.tf` to change default values
- Adding more AWS Config rules in `config_rules.tf`
- Adjusting the S3 bucket lifecycle policy in `s3.tf`

## Security Considerations

- The S3 bucket is configured with encryption and public access blocking
- IAM roles follow the principle of least privilege
- AWS Config is set up to record all supported resource types

## License

This project is licensed under the MIT License - see the LICENSE file for details.
