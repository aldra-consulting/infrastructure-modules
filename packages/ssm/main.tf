# ------------------------------------------------------------------------------
# Module setup
# ------------------------------------------------------------------------------

terraform {
  backend "s3" {}
}

locals {
  region       = var.region.name
  project_name = var.common.project.name
  environment  = var.environment.name
  namespace    = "${local.project_name}-${local.region}-${local.environment}"
  tags         = merge(var.account.tags, var.region.tags, var.environment.tags)
}

provider "aws" {}

# ------------------------------------------------------------------------------
# Module configuration
# ------------------------------------------------------------------------------

resource "aws_ssm_parameter" "ses_configuration" {
  name        = "${local.namespace}-ses-configuration"
  description = "SES configuration parameters (formatted as JSON)"
  type        = "SecureString"
  value       = var.ses_configuration

  lifecycle {
    ignore_changes = [
      value
    ]
  }

  tags = local.tags
}

resource "aws_ssm_parameter" "ses_smtp_users" {
  name        = "${local.namespace}-ses-smtp-users"
  description = "An array of SES SMTP users (formatted as JSON)"
  type        = "SecureString"
  value       = var.ses_smtp_users

  lifecycle {
    ignore_changes = [
      value
    ]
  }

  tags = local.tags
}
