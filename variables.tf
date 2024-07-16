# Tag Variables
# set creation date as a general tag
locals {
  creation_date = formatdate("YYYY-MM-DD", timestamp())
  tags = merge(
    var.tags,
    {
      "CreationDate" = local.creation_date
    }
  )
}

variable "tagName" {
  default = "website"
}

# combined tags
variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {
    "Project" = "capstone"
  }
}

# VPC Variables
variable "cidr_block" {
  default = ["0.0.0.0/0"]
}

variable "availability_zones" {
  default     = ["us-west-2a", "us-west-2b"]
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR block for public subnet"
  default     = ["10.0.0.0/26", "10.0.0.64/26"]
}

# EC2 Variables
variable "ec2_instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "Name of key pair"
  default     = "vockey"
}

# UserData Variables

variable "access_key" {
  default = "<your-access-key>"
  }

variable "secret_key" {
  default = "<your-secret-key>"
  }

variable "session_token" {
  default = "<your-session-token>"
  }

variable "region" {
  default     = "<your-region>"
}

# S3 Bucket Variables

variable "bucket_name" {
  default     = "<your-bucket-name>"
}