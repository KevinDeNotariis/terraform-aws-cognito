locals {
  cognito_root_domain = "${var.environment}.${var.prefix}.${var.root_domain}"
  cognito_pool_domain = "auth.${local.cognito_root_domain}"

  users_config_map  = yamldecode(file(var.users_config_file_path))
  groups_config_map = yamldecode(file(var.groups_config_file_path))
}
