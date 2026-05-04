# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Elastic IP for NAT
resource "aws_eip" "nat" {}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}

# EC2 Instance
resource "aws_instance" "web" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
}

# Load Balancer
resource "aws_lb" "alb" {
  name               = "ramya-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public.id]
}

# Target Group
resource "aws_lb_target_group" "tg" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

# Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  desired_capacity = 1
  max_size         = 2
  min_size         = 1
}
