# Create a VPC
resource "aws_vpc" "website_vpc" {
  cidr_block = "10.0.0.0/16"  
  enable_dns_hostnames = true 
  enable_dns_support = true
  
  tags       =  {
    Name     = "website_vpc"
    Project  = "capstone"
  }       
}

# Create a public subnet
resource "aws_subnet" "public_1" {
  vpc_id     = aws_vpc.website_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "website_public_subnet_1"
    Project  = "capstone"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.website_vpc.id
  tags = {
    Name = "website_IGW"
    Project  = "capstone"
  }
}

# Create a public route table
resource "aws_route_table" "RB_Public_RouteTable" {
  vpc_id = aws_vpc.website_vpc.id

  # route to IGW
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "website_public_route_table"
    Project  = "capstone"
  }
}

# associate public subnet 1 with public route table
resource "aws_route_table_association" "Public_Subnet1_Asso" {
  route_table_id = aws_route_table.RB_Public_RouteTable.id
  subnet_id      = aws_subnet.public_1.id
  depends_on     = [aws_route_table.RB_Public_RouteTable, aws_subnet.public_1]
}