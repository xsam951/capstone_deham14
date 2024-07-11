# Get latest AMI ID of Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Create EC2
resource "aws_instance" "website-ec2" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.ec2_instance_type
  availability_zone = var.availability_zone
  key_name = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.website_sg.id]
  subnet_id = aws_subnet.public_subnet.id

  tags = merge(local.tags, {
    "Name" = "${var.tagName}-EC2"
  }) 
  #user_data = file("userdata.sh")
  user_data = templatefile("${path.module}/userdata.sh", {
    access_key    = var.access_key
    secret_key    = var.secret_key
    session_token = var.session_token
    region        = var.region
    bucket_name   = var.bucket_name
  })
}