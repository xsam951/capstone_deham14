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

variable "availability_zone" {
  default     = "us-west-2a"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for public subnet"
  default     = "10.0.0.0/26"
}

# EC2 Variables
variable "ec2_instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "Name of key pair"
  default     = "vockey"
}
