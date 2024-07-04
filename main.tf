# specifies the terraform workspace
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.55.0"
    }
  }
}

# aws region to connect to
provider "aws" {
  region = "us-west-2"
}
