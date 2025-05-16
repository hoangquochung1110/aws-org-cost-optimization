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

# Custom Config Rule - EBS Volume Type Check
resource "aws_config_config_rule" "ebs_volume_type_check" {
  name        = "ebs-volume-type-check"
  description = "Checks for EBS volumes that are using gp2 and should be converted to gp3"

  evaluation_mode {
      mode = "DETECTIVE"
  }

  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = var.ebs_volume_check_lambda_arn

    source_detail {
        event_source                = "aws.config"
        maximum_execution_frequency = null
        message_type                = "ConfigurationItemChangeNotification"
    }
    source_detail {
        event_source                = "aws.config"
        maximum_execution_frequency = null
        message_type                = "OversizedConfigurationItemChangeNotification"
    }
  }

  scope {
    compliance_resource_types = ["AWS::EC2::Volume"]
  }

  depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_remediation_configuration" "ebs_volume_type_check" {
  automatic                  = true
  config_rule_name           = "ebs-volume-type-check"
  maximum_automatic_attempts = 1
  resource_type              = null
  retry_attempt_seconds      = 60
  target_id                  = "AWSConfigRemediation-ModifyEBSVolumeType"
  target_type                = "SSM_DOCUMENT"
  target_version             = "2"

  parameter {
      name           = "AutomationAssumeRole"
      resource_value = null
      static_value   = var.ssm_automation_role_arn
      static_values  = []
  }
  parameter {
      name           = "EbsVolumeId"
      resource_value = "RESOURCE_ID"
      static_value   = null
      static_values  = []
  }
  parameter {
      name           = "EbsVolumeType"
      resource_value = null
      static_value   = "gp3"
      static_values  = []
  }
}

