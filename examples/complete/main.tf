variable "hosted_zone_name" {}

locals {
  prefix      = "complete"
  identifier  = random_id.this.hex
  environment = "test"
}

data "aws_route53_zone" "current" {
  name = var.hosted_zone_name
}

resource "random_id" "this" {
  byte_length = 4
}

module "cognito" {
  source = "../.."

  prefix      = local.prefix
  identifier  = local.identifier
  environment = local.environment

  root_domain    = var.hosted_zone_name
  hosted_zone_id = data.aws_route53_zone.current.zone_id

  users_config_file_path         = "${path.module}/config/users.yaml"
  groups_config_file_path        = "${path.module}/config/groups.yaml"
  user_pool_client_callback_urls = ["http://localhost:3000/"]
  user_pool_client_logout_urls   = ["http://localhost:3000/"]

  verification_email_subject_by_link      = "Jungle - Email Confirmation"
  verification_email_message_by_link_path = "${path.module}/config/verification_email_message.txt"

  invite_email_subject      = "Welcome to the Jungle"
  invite_email_message_path = "${path.module}/config/invite_email_message.txt"
  invite_sms_message        = "Hello {username}, please sign up at: {####}"

  user_pool_schemas = [
    {
      name                     = "id"
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = false
      required                 = false
    }
  ]

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
