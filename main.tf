#====================================================================================
# User Pool
#====================================================================================
resource "aws_cognito_user_pool" "this" {
  name = "${var.prefix}-${var.identifier}"

  auto_verified_attributes = ["email"]
  verification_message_template {
    default_email_option  = "CONFIRM_WITH_LINK"
    email_subject_by_link = var.verification_email_subject_by_link
    email_message_by_link = file(var.verification_email_message_by_link_path)
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
    invite_message_template {
      email_subject = var.invite_email_subject
      email_message = file(var.invite_email_message_path)
      sms_message   = var.invite_sms_message
    }
  }

  username_configuration {
    case_sensitive = false
  }

  password_policy {
    minimum_length                   = 14
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true

    string_attribute_constraints {
      min_length = 6
      max_length = 255
    }
  }

  schema {
    name                     = "given_name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    required                 = true

    string_attribute_constraints {
      min_length = 2
      max_length = 255
    }
  }

  schema {
    name                     = "family_name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    required                 = true

    string_attribute_constraints {
      min_length = 2
      max_length = 255
    }
  }

  dynamic "schema" {
    for_each = toset(var.user_pool_schemas)

    content {
      name                     = schema.value.name
      attribute_data_type      = schema.value.attribute_data_type
      developer_only_attribute = schema.value.required
      mutable                  = schema.value.mutable
      required                 = schema.value.required

      dynamic "string_attribute_constraints" {
        for_each = schema.value.attribute_data_type == "String" ? [1] : []

        content {
          min_length = 2
          max_length = 255
        }
      }
    }
  }
}

#====================================================================================
# Certificate for the Pool Custom Domain
#====================================================================================
resource "aws_acm_certificate" "this" {
  domain_name       = local.cognito_pool_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  provider = aws.us_east_1
}

resource "aws_route53_record" "cert_validation" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_type
  zone_id         = var.hosted_zone_id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]

  provider = aws.us_east_1
}

#====================================================================================
# User Pool Custom Domain
#
# NOTES: https://repost.aws/knowledge-center/cognito-custom-domain-errors
#
# The root domain, in our case var.root_domain, needs to be resolvable to
# an IP before cognito can create the custom domain. In order to do that,
# we can create a dummy A record pointing to 8.8.8.8, create the custom record
# and then delete the dummy record.
#====================================================================================
resource "aws_cognito_user_pool_domain" "this" {
  domain          = local.cognito_pool_domain
  user_pool_id    = aws_cognito_user_pool.this.id
  certificate_arn = aws_acm_certificate_validation.this.certificate_arn

  depends_on = [
    aws_route53_record.dummy
  ]
}

resource "aws_route53_record" "dummy" {
  name    = local.cognito_root_domain
  type    = "A"
  zone_id = var.hosted_zone_id
  records = ["8.8.8.8"]
  ttl     = 300
}

resource "aws_route53_record" "cognito_user_pool_domain" {
  name    = aws_cognito_user_pool_domain.this.domain
  type    = "A"
  zone_id = var.hosted_zone_id
  alias {
    evaluate_target_health = false

    name    = aws_cognito_user_pool_domain.this.cloudfront_distribution
    zone_id = aws_cognito_user_pool_domain.this.cloudfront_distribution_zone_id
  }
}

#====================================================================================
# Pool Client With Cognito as IdP
#====================================================================================
resource "aws_cognito_user_pool_client" "this" {
  name                                 = "${var.prefix}-${var.identifier}"
  user_pool_id                         = aws_cognito_user_pool.this.id
  callback_urls                        = var.user_pool_client_callback_urls
  logout_urls                          = var.user_pool_client_logout_urls
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = var.oauth_flows
  allowed_oauth_scopes                 = var.oath_scopes
  supported_identity_providers         = var.supported_identity_provider
  explicit_auth_flows                  = var.explicit_auth_flows
}

#====================================================================================
# Create an Identity pool
#====================================================================================
resource "aws_cognito_identity_pool" "this" {
  identity_pool_name               = "${var.prefix}-${var.identifier}"
  allow_unauthenticated_identities = true
  allow_classic_flow               = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.this.id
    provider_name           = aws_cognito_user_pool.this.endpoint
    server_side_token_check = false
  }
}

data "aws_iam_policy_document" "cognito_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.this.id]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }
  }
}

data "aws_iam_policy_document" "cognito_unauthenticated_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.this.id]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["unauthenticated"]
    }
  }
}

resource "aws_iam_role" "cognito_user" {
  count = var.iam_cognito_authenticated_user_policy_json != null ? 1 : 0

  name               = "${var.prefix}-cognito-groups-${var.identifier}"
  assume_role_policy = data.aws_iam_policy_document.cognito_assume.json
}

resource "aws_iam_role_policy" "cognito_user" {
  count = var.iam_cognito_authenticated_user_policy_json != null ? 1 : 0

  role   = aws_iam_role.cognito_user[0].id
  name   = "custom"
  policy = var.iam_cognito_authenticated_user_policy_json
}

resource "aws_iam_role" "cognito_unauthenticated_user" {
  count = var.iam_cognito_unauthenticated_user_policy_json != null ? 1 : 0

  name               = "${var.prefix}-cognito-unauthenticated-${var.identifier}"
  assume_role_policy = data.aws_iam_policy_document.cognito_unauthenticated_assume.json
}

resource "aws_iam_role_policy" "cognito_unauthenticated_user" {
  count = var.iam_cognito_unauthenticated_user_policy_json != null ? 1 : 0

  role   = aws_iam_role.cognito_unauthenticated_user[0].id
  name   = "custom"
  policy = var.iam_cognito_unauthenticated_user_policy_json
}

resource "aws_cognito_identity_pool_roles_attachment" "this" {
  count = var.iam_cognito_authenticated_user_policy_json == null && var.iam_cognito_unauthenticated_user_policy_json == null ? 0 : 1

  identity_pool_id = aws_cognito_identity_pool.this.id

  role_mapping {
    identity_provider         = "${aws_cognito_user_pool.this.endpoint}:${aws_cognito_user_pool_client.this.id}"
    type                      = "Token"
    ambiguous_role_resolution = "AuthenticatedRole"
  }

  roles = var.iam_cognito_authenticated_user_policy_json == null ? {
    "unauthenticated" = aws_iam_role.cognito_unauthenticated_user[0].arn
    } : var.iam_cognito_unauthenticated_user_policy_json == null ? {
    "authenticated" = aws_iam_role.cognito_user[0].arn
    } : {
    "unauthenticated" = aws_iam_role.cognito_unauthenticated_user[0].arn
    "authenticated"   = aws_iam_role.cognito_user[0].arn
  }
}

#====================================================================================
# Create Groups
#====================================================================================
resource "aws_cognito_user_group" "this" {
  for_each = local.groups_config_map

  user_pool_id = aws_cognito_user_pool.this.id
  name         = each.key
}

#====================================================================================
# Create Users
#====================================================================================
resource "random_uuid" "this" {
  for_each = local.users_config_map
}

resource "aws_cognito_user" "this" {
  for_each = local.users_config_map

  user_pool_id = aws_cognito_user_pool.this.id
  username     = each.key

  attributes = {
    email          = each.value.email
    given_name     = each.value.given_name
    family_name    = each.value.family_name
    id             = random_uuid.this[each.key].result
    email_verified = true
  }
}

#====================================================================================
# Associate Users to Groups
#====================================================================================
resource "aws_cognito_user_in_group" "this" {
  for_each = {
    for elem in flatten([
      for user, config in local.users_config_map : flatten([
        for group in config.groups : {
          group = group
          user  = user
        }
      ])
    ]) : "${elem.user}_${elem.group}" => elem
  }

  group_name   = each.value.group
  user_pool_id = aws_cognito_user_pool.this.id
  username     = aws_cognito_user.this[each.value.user].username
}

#====================================================================================
# Parameter Store
#====================================================================================
resource "aws_ssm_parameter" "cognito_user_pool_client_id" {
  name  = "/${var.prefix}-${var.identifier}/cognito/user-pool/client-id"
  type  = "SecureString"
  value = aws_cognito_user_pool_client.this.id
}
