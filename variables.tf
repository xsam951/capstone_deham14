# Tag Variables
variable "tagDate" {
  default = "2024-07-06"
}

variable "tagName" {
  default = "website"
}

variable "tagProject" {
  default = "capstone"
}

# VPC Variables
variable "cidr_block" {
  default = "0.0.0.0/0"
}

variable "availability_zone" {
  default     = "us-west-2a"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for public subnet"
  default     = "10.0.0.0/26"
}
