output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool."
  value       = aws_cognito_user_pool.this.id
}

output "cognito_identity_pool_id" {
  description = "The ID of the Cognito Identity Pool."
  value       = aws_cognito_identity_pool.this.id
}

output "cognito_user_pool_arn" {
  description = "The ARN of the Cognito User Pool."
  value       = aws_cognito_user_pool.this.arn
}

output "cognito_user_pool_domain" {
  description = "The domain of the Cognito User Pool."
  value       = aws_cognito_user_pool_domain.this.domain
}

output "cognito_user_pool_client_id" {
  description = "The Client ID of the Cognito User Pool."
  value       = aws_cognito_user_pool_client.this.id
}

output "cognito_user_pool_client_id_ssm_parameter_name" {
  description = "The name of the SSM Parameter storing the Cognito User Pool Client ID."
  value       = aws_ssm_parameter.cognito_user_pool_client_id.name
}
