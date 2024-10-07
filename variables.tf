variable "prefix" {
  description = "Prefix for the resource names"
  type        = string
}

variable "identifier" {
  description = "The identifier for the deployment"
  type        = string
}

variable "environment" {
  description = "The environment where the module will be deployed"
  type        = string
}

variable "root_domain" {
  description = "The root domain which will be used as base for the Cognito domain"
  type        = string
}

variable "hosted_zone_id" {
  description = "The Id of the hosted zone where the records needs to be created"
  type        = string
}

variable "users_config_file_path" {
  description = "The file path where the users config for the congito are stored"
  type        = string
}

variable "user_pool_client_callback_urls" {
  description = "The URLs that will be allowed to be called back after a successful login"
  type        = list(string)
}

variable "user_pool_client_logout_urls" {
  description = "The URLs that will be allowed to be called back after a successful logout"
  type        = list(string)
}

variable "groups_config_file_path" {
  description = "The file path where the groups config for the congito are stored"
  type        = string
}

variable "verification_email_subject_by_link" {
  description = "Subject line for the email message template for sending a confirmation link to the user."
  type        = string
}

variable "verification_email_message_by_link_path" {
  description = "Path to the file containing the email message template for sending a confirmation link to the user, it must contain the {##Click Here##} placeholder."
  type        = string
}

variable "invite_email_subject" {
  description = "Subject line for the email message template."
  type        = string
}

variable "invite_email_message_path" {
  description = "Path to the file containing email message template for sending a confirmation link to the user, it must contain the {##Click Here##} placeholder"
  type        = string
}

variable "invite_sms_message" {
  description = "SMS message template. Must contain the {####} placeholder."
  type        = string
}

variable "user_pool_schemas" {
  description = "Schemas for attributes defined for users"
  type = list(object({
    name                     = string
    attribute_data_type      = string
    required                 = optional(bool, true)
    mutable                  = optional(bool, false)
    developer_only_attribute = optional(bool, false)
  }))

  default = []
}

variable "oauth_flows" {
  description = "List of allowed OAuth flows, including code, implicit, and client_credentials"
  type        = list(string)
  default     = ["code", "implicit"]
}

variable "oauth_scopes" {
  description = "List of allowed OAuth scopes, including phone, email, openid, profile, and aws.cognito.signin.user.admin"
  type        = list(string)
  default     = ["email", "openid", "profile"]
}

variable "supported_identity_provider" {
  description = "List of provider names for the identity providers that are supported on this client. It uses the provider_name attribute of the aws_cognito_identity_provider resource(s), or the equivalent string(s)."
  type        = list(string)
  default     = ["COGNITO"]
}

variable "explicit_auth_flows" {
  description = "List of authentication flows"
  type        = list(string)
  default = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

variable "create_dummy_record" {
  description = "Whether to create a dummy record for the user pool domain to be correctly created the first time. This is necessary when first creating the user pool domain, after that, this variable can be set to false to destroy the dummy record"
  type        = bool
  default     = true
}

variable "iam_cognito_unauthenticated_user_policy_json" {
  description = "Json policy that will be associated with an unauthenticated user at identity pool level"
  type        = string
  default     = null
}

variable "iam_cognito_authenticated_user_policy_json" {
  description = "Json policy that will be associated with an authenticated user at identity pool level"
  type        = string
  default     = null
}
