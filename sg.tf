# Create security group and rules for webservers
resource "aws_security_group" "website_sg" {
  name        = "website-sg"
  description = "Security group for Website instance"

  vpc_id = aws_vpc.website_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_public_ip]
  }

  ingress {
    description = "HTTP from ELB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    #cidr_blocks = var.cidr_block
    security_groups = [aws_security_group.elb_sg.id]
  }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_block
  }

  tags = merge(local.tags, {
    "Name" = "${var.tagName}-EC2-SG"
  })    
}

# Create security group and rules for the ELB
resource "aws_security_group" "elb_sg" {
  name        = "elb-sg"
  description = "Security group for ELB"

  vpc_id = aws_vpc.website_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.cidr_block
  }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_block
  }

  tags = merge(local.tags, {
    "Name" = "${var.tagName}-ELB-SG"
  })    
}

# Create security group and rules for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for RDS"

  vpc_id = aws_vpc.website_vpc.id

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.website_sg.id]
  }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_block
  }

  tags = merge(local.tags, {
    "Name" = "${var.tagName}-RDS-SG"
  })    
}