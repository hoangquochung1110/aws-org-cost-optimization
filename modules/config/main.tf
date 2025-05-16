# AWS Config Recorder
# this resource does not start the created recorder automatically
resource "aws_config_configuration_recorder" "config_recorder" {
  name     = "${var.project_name}-config-recorder"
  role_arn = var.config_role_arn
}

# AWS Config Delivery Channel
resource "aws_config_delivery_channel" "config_delivery_channel" {
  name           = "${var.project_name}-config-delivery-channel"
  s3_bucket_name = var.config_bucket
  s3_key_prefix  = "config"

  depends_on = [aws_config_configuration_recorder.config_recorder]
}

# Enable AWS Config Recorder
# Manages status (recording / stopped) of an AWS Config Configuration Recorder
resource "aws_config_configuration_recorder_status" "config_recorder_status" {
  name       = aws_config_configuration_recorder.config_recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.config_delivery_channel]
}

# AWS Managed Config Rule - EBS Encryption
resource "aws_config_config_rule" "ec2-ebs-encryption-by-default" {
  name        = "ec2-ebs-encryption-by-default"
  description = "Checks whether EBS volumes are encrypted"

  source {
    owner             = "AWS"
    source_identifier = "EC2_EBS_ENCRYPTION_BY_DEFAULT"
  }

  evaluation_mode {
    mode = "DETECTIVE"
  }

  depends_on = [aws_config_configuration_recorder.config_recorder]
}
