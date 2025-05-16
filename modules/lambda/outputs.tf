output "ebs_volume_check_lambda_arn" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.ebs_volume_check.arn
}
