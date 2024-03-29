# ------------------------------------------------------------------------------
# Module setup
# ------------------------------------------------------------------------------

terraform {
  backend "s3" {}
}

locals {
  domain_name = var.environment.project.domain_name
  namespace   = var.namespace
  tags        = var.tags
}

provider "aws" {}

# ------------------------------------------------------------------------------
# Module configuration
# ------------------------------------------------------------------------------

data "aws_ses_domain_identity" "this" {
  domain = local.domain_name
}

resource "aws_cognito_user_pool" "this" {
  name = "${local.namespace}-user-pool"

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  username_attributes = [
    "email",
    "phone_number"
  ]

  auto_verified_attributes = [
    "email"
  ]

  device_configuration {}

  email_configuration {
    email_sending_account = "DEVELOPER"
    from_email_address    = "Aldra Consulting <accounts@${local.domain_name}>"
    source_arn            = data.aws_ses_domain_identity.this.arn
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "Account Verification | Aldra Consulting"
    email_message        = "Your verification code is {####}."
  }

  mfa_configuration = "OPTIONAL"

  password_policy {
    minimum_length                   = 8
    require_lowercase                = false
    require_numbers                  = false
    require_symbols                  = false
    require_uppercase                = false
    temporary_password_validity_days = 7
  }

  software_token_mfa_configuration {
    enabled = true
  }

  tags = local.tags
}

resource "aws_cognito_user_pool_client" "this" {
  name = "auth-rest-api-client"

  user_pool_id = aws_cognito_user_pool.this.id

  explicit_auth_flows = [
    "ADMIN_NO_SRP_AUTH"
  ]
}
