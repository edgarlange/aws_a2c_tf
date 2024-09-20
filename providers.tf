terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.47.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}
provider "aws" {
  region  = var.tf_provider_region
  profile = var.tf_provider_aws_profile
}
