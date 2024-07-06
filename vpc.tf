# Create a VPC
resource "aws_vpc" "website_vpc" {
  cidr_block = "10.0.0.0/24"  
  enable_dns_hostnames = true 
  enable_dns_support = true
  
  tags = merge(local.tags, {
    "Name" = "${var.tagName}-VPC"
  })     
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.website_vpc.id
  cidr_block = var.public_subnet_cidr_block
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    "Name" = "${var.tagName}-PublicSubnet"
  })    
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.website_vpc.id

  tags = merge(local.tags, {
    "Name" = "${var.tagName}-IGW"
  }) 
}

# Create a public route table
resource "aws_route_table" "Public_RouteTable" {
  vpc_id = aws_vpc.website_vpc.id

  # route to IGW
  route {
    cidr_block = var.cidr_block[0]
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(local.tags, {
    "Name" = "${var.tagName}-PublicRouteTable"
  }) 
}

# associate public subnet 1 with public route table
resource "aws_route_table_association" "Public_Subnet1_Asso" {
  route_table_id = aws_route_table.Public_RouteTable.id
  subnet_id      = aws_subnet.public_subnet.id
  depends_on     = [aws_route_table.Public_RouteTable, aws_subnet.public_subnet]
}