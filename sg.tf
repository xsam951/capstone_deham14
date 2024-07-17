resource "aws_security_group" "website_sg" {
  name        = "website-sg"
  description = "Security group for Website instance"

  vpc_id = aws_vpc.website_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.cidr_block
    
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