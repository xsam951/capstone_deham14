resource "aws_lb" "website_elb" {
  name               = "website-elb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id]
  security_groups    = [aws_security_group.website_sg.id]

  enable_deletion_protection = false

  tags = merge(local.tags, {
    "Name" = "${var.tagName}-ELB"
  })  
}

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

resource "aws_lb_target_group_attachment" "website_target_group_attachment" {
  target_group_arn = aws_lb_target_group.website_target_group.arn
  
  target_id        = aws_instance.website_ec2.id
  port             = 80
}

# resource "aws_autoscaling_attachment" "name" {
#   autoscaling_group_name = aws_autoscaling_group.website_autoscaling_group.id
#   lb_target_group_arn   = aws_lb_target_group.website_target_group.arn
  
# }

resource "aws_lb_listener" "website_listener" {
  load_balancer_arn = aws_lb.website_elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.website_target_group.arn
  }
}