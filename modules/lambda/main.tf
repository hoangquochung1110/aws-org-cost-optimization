# Archive the Lambda function code
data "archive_file" "ebs_volume_check" {
  type        = "zip"
  output_path = "${path.module}/ebs_volume_check.zip"
  source_dir  = "${path.root}/functions/ebs_volume_check"
}

# Create Lambda function
resource "aws_lambda_function" "ebs_volume_check" {
  filename         = data.archive_file.ebs_volume_check.output_path
  function_name    = "ebs-volume-type-check"
  role            = var.lambda_role_arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.ebs_volume_check.output_base64sha256
  runtime         = "python3.9"
  timeout         = 30
  
  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }

  tags = {
    Name = "EBS Volume Type Check"
  }
}

# Allow AWS Config to invoke the Lambda function
resource "aws_lambda_permission" "allow_config" {
  statement_id  = "AllowConfigToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ebs_volume_check.function_name
  principal     = "config.amazonaws.com"
}
