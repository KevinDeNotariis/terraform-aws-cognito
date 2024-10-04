output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.this.id
}

output "cognito_identity_pool_id" {
  value = aws_cognito_identity_pool.this.id
}

output "cognito_user_pool_arn" {
  value = aws_cognito_user_pool.this.arn
}

output "cognito_user_pool_domain" {
  value = aws_cognito_user_pool_domain.this.domain
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.this.id
}

output "cognito_user_pool_client_id_ssm_parameter_name" {
  value = aws_ssm_parameter.cognito_user_pool_client_id.name
}
