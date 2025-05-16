# IAM Role for AWS Config
resource "aws_iam_role" "config_role" {
  name = "${var.project_name}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach AWS managed policy for Config
resource "aws_iam_role_policy_attachment" "config_policy_attachment" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}


# IAM Role for Lambda
resource "aws_iam_role" "ebs_volume_check_function_role" {
  name = "${var.project_name}-ebs-volume-check-function-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Lambda basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.ebs_volume_check_function_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom policy for Lambda to describe EC2 volumes
resource "aws_iam_role_policy" "describe_volume" {
  name = "${var.project_name}-describe-volume-policy"
  role = aws_iam_role.ebs_volume_check_function_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "config:GetResourceConfigHistory"
        ]
        Resource = "*"
      }
    ]
  })
}

# Custom policy for Lambda to resource config history
resource "aws_iam_role_policy" "get_resource_config_history" {
  name = "${var.project_name}-get-resource-config-history"
  role = aws_iam_role.ebs_volume_check_function_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "config:GetResourceConfigHistory"
        ]
        Resource = "*"
      }
    ]
  })
}

# Custom policy for Lambda to resource config history
resource "aws_iam_role_policy" "put_evaluation" {
  name = "${var.project_name}-put-evaluation"
  role = aws_iam_role.ebs_volume_check_function_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "config:PutEvaluations"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Role for AWS Config Remediation
resource "aws_iam_role" "config_remediation_role" {
  name = "${var.project_name}-config-remediation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Inline policy for Config remediation
resource "aws_iam_role_policy" "config_remediation_policy" {
  name = "config-remediation-policy"
  role = aws_iam_role.config_remediation_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:StartAutomationExecution"
        ]
        Resource = "arn:aws:ssm:*:*:automation-definition/ConvertEBSVolumeToGp3:*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = aws_iam_role.ssm_automation_role.arn
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ssm.amazonaws.com"
          }
        }
      }
    ]
  })
}

# IAM Role for SSM Automation
resource "aws_iam_role" "ssm_automation_role" {
  name = "${var.project_name}-ssm-automation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Inline policy for SSM Automation
resource "aws_iam_role_policy" "ssm_automation_policy" {
  name = "ssm-automation-policy"
  role = aws_iam_role.ssm_automation_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVolumes"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:ModifyVolume"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateTags"
        ]
        Resource = "arn:aws:ec2:*:*:volume/*"
      }
    ]
  })
}