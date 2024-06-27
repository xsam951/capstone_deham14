# specifies the terraform workspace
terraform {
  cloud {
    organization = "free-tier-deham14"

    workspaces {
      name = "Capstone_deham14"
    }
  }
}

# provider to connect to aws
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 3.0"
    }
  }
}

# aws region to connect to
provider "aws" {
  region = "us-west-2"
}