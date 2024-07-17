# Create ELB for traffic routing between instances
resource "aws_lb" "website_elb" {
  name               = "website-elb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id]
  security_groups    = [aws_security_group.elb_sg.id]

  enable_deletion_protection = false

  tags = merge(local.tags, {
    "Name" = "${var.tagName}-ELB"
  })  
}

# output ELB DNS
output "elb_dns_name" {
  value = aws_lb.website_elb.dns_name
}

# Create target group for ELB
resource "aws_lb_target_group" "website_target_group" {
  name        = "website-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.website_vpc.id
  target_type = "instance"

  tags = merge(local.tags, {
    "Name" = "${var.tagName}-target-group"
  })  
}

# Create listener for ELB
resource "aws_lb_listener" "website_listener" {
  load_balancer_arn = aws_lb.website_elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.website_target_group.arn
  }
}