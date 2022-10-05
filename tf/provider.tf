
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  shared_credentials_files = [var.shared_credentials_file]
  profile = var.shared_credentials_file_profile
}