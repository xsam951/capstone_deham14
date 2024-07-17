
resource "aws_launch_configuration" "scaling_launch_config" {
  image_id        = data.aws_ami.amazon_linux_2.id
  instance_type   = var.ec2_instance_type
  security_groups = ["${aws_security_group.website_sg.id}"]
  key_name        = var.key_name
}

resource "aws_autoscaling_group" "website_autoscaling_group" {
  launch_template {
    id      = aws_launch_template.scaling_launch_template.id
    version = "$Latest"
  }
  name                      = "website-asg"
  min_size                  = 1
  max_size                  = 4
  desired_capacity          = 2
  vpc_zone_identifier       = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id]
  target_group_arns         = [aws_lb_target_group.website_target_group.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 900

  tag {
    key                 = "Name"
    value               = "${var.tagName}-ec2"
    propagate_at_launch = true
  }
}

#Create a launch template
resource "aws_launch_template" "scaling_launch_template" {
  name_prefix            = "scaling_launch_template"
  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = var.ec2_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.website_sg.id]
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    access_key    = var.access_key
    secret_key    = var.secret_key
    session_token = var.session_token
    region        = var.region
    bucket_name   = var.bucket_name
  }))

  lifecycle {
    create_before_destroy = true
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge(local.tags, {
        "Name" = "${var.tagName}-template-EC2"
    }) 
  }
  tags = merge(local.tags, {
        "Name" = "${var.tagName}-launch-template"
    }) 
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale_out"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.website_autoscaling_group.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
} 

resource "aws_autoscaling_attachment" "asg_lb_attachment" {
  autoscaling_group_name = aws_autoscaling_group.website_autoscaling_group.id
  lb_target_group_arn   = aws_lb_target_group.website_target_group.arn
}