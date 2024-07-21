# Tag Variables
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

# VPC Variables
variable "cidr_block" {
  default = ["0.0.0.0/0"]
}

variable "availability_zones" {
  default     = ["us-west-2a", "us-west-2b"]
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR block for public subnet"
  default     = ["10.0.0.0/28", "10.0.0.16/28"]
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR block for private subnet"
  default     = ["10.0.0.32/28", "10.0.0.48/28"]
}

# Security Variables

# get local IP address
data "http" "myip" {
  url = "https://ipinfo.io/ip"
}

locals {
  my_public_ip = "${chomp(data.http.myip.response_body)}/32"
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

# RDS Variables

variable "rds_username" {
  description = "The username for the RDS instance"
  default     = "<your-RDS-username>"
}
variable "rds_password" {
  description = "The password for the RDS instance"
  sensitive   = true
  default     = "<your-RDS-password>"
}
variable "rds_db_name" {
  description = "The name of the database"
  default     = "<your-RDS-db-name>"
}