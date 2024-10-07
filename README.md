# AWS Cognito Terraform module

Terraform module that is in charge of creating a usable cognito user pool and identity pool with all the necessary resources.

## Features

- Creates an identity pool with standardized presence and definition of compulsory attributes:
  - email
  - given_name
  - family_name
- Set up the user pool for verification of a new user via email and with a invite message via email.
- Create a custom domain (with its certificate) for the user pool in the form of:

    ```txt
    auth.<environment>.<prefix>.<base_domain>
    ```
- Create a user pool client
- Create an identity pool which will allow to assign AWS permissions on user logged in (or not logged in)
- Extract the groups and users to be created from two distinct YAML files.
- Save in SSM Paramater store the client-id of the user pool client.
- 
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.70.0 |
| <a name="provider_aws.us_east_1"></a> [aws.us\_east\_1](#provider\_aws.us\_east\_1) | 5.70.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cognito_identity_pool.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_pool) | resource |
| [aws_cognito_identity_pool_roles_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_pool_roles_attachment) | resource |
| [aws_cognito_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user) | resource |
| [aws_cognito_user_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_group) | resource |
| [aws_cognito_user_in_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_in_group) | resource |
| [aws_cognito_user_pool.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_client.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_cognito_user_pool_domain.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |
| [aws_iam_role.cognito_unauthenticated_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.cognito_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cognito_unauthenticated_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.cognito_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_route53_record.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.cognito_user_pool_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.dummy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ssm_parameter.cognito_user_pool_client_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_uuid.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [aws_iam_policy_document.cognito_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cognito_unauthenticated_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_dummy_record"></a> [create\_dummy\_record](#input\_create\_dummy\_record) | Whether to create a dummy record for the user pool domain to be correctly created the first time. This is necessary when first creating the user pool domain, after that, this variable can be set to false to destroy the dummy record | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment where the module will be deployed | `string` | n/a | yes |
| <a name="input_explicit_auth_flows"></a> [explicit\_auth\_flows](#input\_explicit\_auth\_flows) | List of authentication flows | `list(string)` | <pre>[<br/>  "ALLOW_USER_PASSWORD_AUTH",<br/>  "ALLOW_ADMIN_USER_PASSWORD_AUTH",<br/>  "ALLOW_REFRESH_TOKEN_AUTH",<br/>  "ALLOW_USER_SRP_AUTH"<br/>]</pre> | no |
| <a name="input_groups_config_file_path"></a> [groups\_config\_file\_path](#input\_groups\_config\_file\_path) | The file path where the groups config for the congito are stored | `string` | n/a | yes |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | The Id of the hosted zone where the records needs to be created | `string` | n/a | yes |
| <a name="input_iam_cognito_authenticated_user_policy_json"></a> [iam\_cognito\_authenticated\_user\_policy\_json](#input\_iam\_cognito\_authenticated\_user\_policy\_json) | Json policy that will be associated with an authenticated user at identity pool level | `string` | `null` | no |
| <a name="input_iam_cognito_unauthenticated_user_policy_json"></a> [iam\_cognito\_unauthenticated\_user\_policy\_json](#input\_iam\_cognito\_unauthenticated\_user\_policy\_json) | Json policy that will be associated with an unauthenticated user at identity pool level | `string` | `null` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | The identifier for the deployment | `string` | n/a | yes |
| <a name="input_invite_email_message_path"></a> [invite\_email\_message\_path](#input\_invite\_email\_message\_path) | Path to the file containing email message template for sending a confirmation link to the user, it must contain the {##Click Here##} placeholder | `string` | n/a | yes |
| <a name="input_invite_email_subject"></a> [invite\_email\_subject](#input\_invite\_email\_subject) | Subject line for the email message template. | `string` | n/a | yes |
| <a name="input_invite_sms_message"></a> [invite\_sms\_message](#input\_invite\_sms\_message) | SMS message template. Must contain the {####} placeholder. | `string` | n/a | yes |
| <a name="input_oauth_flows"></a> [oauth\_flows](#input\_oauth\_flows) | List of allowed OAuth flows, including code, implicit, and client\_credentials | `list(string)` | <pre>[<br/>  "code",<br/>  "implicit"<br/>]</pre> | no |
| <a name="input_oauth_scopes"></a> [oauth\_scopes](#input\_oauth\_scopes) | List of allowed OAuth scopes, including phone, email, openid, profile, and aws.cognito.signin.user.admin | `list(string)` | <pre>[<br/>  "email",<br/>  "openid",<br/>  "profile"<br/>]</pre> | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for the resource names | `string` | n/a | yes |
| <a name="input_root_domain"></a> [root\_domain](#input\_root\_domain) | The root domain which will be used as base for the Cognito domain | `string` | n/a | yes |
| <a name="input_supported_identity_provider"></a> [supported\_identity\_provider](#input\_supported\_identity\_provider) | List of provider names for the identity providers that are supported on this client. It uses the provider\_name attribute of the aws\_cognito\_identity\_provider resource(s), or the equivalent string(s). | `list(string)` | <pre>[<br/>  "COGNITO"<br/>]</pre> | no |
| <a name="input_user_pool_client_callback_urls"></a> [user\_pool\_client\_callback\_urls](#input\_user\_pool\_client\_callback\_urls) | The URLs that will be allowed to be called back after a successful login | `list(string)` | n/a | yes |
| <a name="input_user_pool_client_logout_urls"></a> [user\_pool\_client\_logout\_urls](#input\_user\_pool\_client\_logout\_urls) | The URLs that will be allowed to be called back after a successful logout | `list(string)` | n/a | yes |
| <a name="input_user_pool_schemas"></a> [user\_pool\_schemas](#input\_user\_pool\_schemas) | Schemas for attributes defined for users | <pre>list(object({<br/>    name                     = string<br/>    attribute_data_type      = string<br/>    required                 = optional(bool, true)<br/>    mutable                  = optional(bool, false)<br/>    developer_only_attribute = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_users_config_file_path"></a> [users\_config\_file\_path](#input\_users\_config\_file\_path) | The file path where the users config for the congito are stored | `string` | n/a | yes |
| <a name="input_verification_email_message_by_link_path"></a> [verification\_email\_message\_by\_link\_path](#input\_verification\_email\_message\_by\_link\_path) | Path to the file containing the email message template for sending a confirmation link to the user, it must contain the {##Click Here##} placeholder. | `string` | n/a | yes |
| <a name="input_verification_email_subject_by_link"></a> [verification\_email\_subject\_by\_link](#input\_verification\_email\_subject\_by\_link) | Subject line for the email message template for sending a confirmation link to the user. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cognito_identity_pool_id"></a> [cognito\_identity\_pool\_id](#output\_cognito\_identity\_pool\_id) | The ID of the Cognito Identity Pool. |
| <a name="output_cognito_user_pool_arn"></a> [cognito\_user\_pool\_arn](#output\_cognito\_user\_pool\_arn) | The ARN of the Cognito User Pool. |
| <a name="output_cognito_user_pool_client_id"></a> [cognito\_user\_pool\_client\_id](#output\_cognito\_user\_pool\_client\_id) | The Client ID of the Cognito User Pool. |
| <a name="output_cognito_user_pool_client_id_ssm_parameter_name"></a> [cognito\_user\_pool\_client\_id\_ssm\_parameter\_name](#output\_cognito\_user\_pool\_client\_id\_ssm\_parameter\_name) | The name of the SSM Parameter storing the Cognito User Pool Client ID. |
| <a name="output_cognito_user_pool_domain"></a> [cognito\_user\_pool\_domain](#output\_cognito\_user\_pool\_domain) | The domain of the Cognito User Pool. |
| <a name="output_cognito_user_pool_id"></a> [cognito\_user\_pool\_id](#output\_cognito\_user\_pool\_id) | The ID of the Cognito User Pool. |
