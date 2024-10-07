terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5"
      configuration_aliases = [aws, aws.us_east_1]
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3"
    }
  }
  required_version = ">= 1.5"
}
