# specifies the terraform workspace
terraform {
  cloud {
    organization = "sandbox-deham14-sam"

    workspaces {
      name = "Sandbox_deham14"
    }
  }
}

# provider to connect to aws
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.55.0"
    }
  }
}

# aws region to connect to
provider "aws" {
  region = "us-west-2"
}