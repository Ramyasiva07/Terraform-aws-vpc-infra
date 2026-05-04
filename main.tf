# ---------------- VPC ----------------
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

# ---------------- SUBNETS ----------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
}

# ---------------- INTERNET GATEWAY ----------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# ---------------- NAT ----------------
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}

# ---------------- ROUTE TABLES ----------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# ---------------- SECURITY GROUP ----------------
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------- LOAD BALANCER ----------------
resource "aws_lb" "alb" {
  name               = "ramya-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public.id]
  security_groups    = [aws_security_group.web_sg.id]
}

# ---------------- TARGET GROUP ----------------
resource "aws_lb_target_group" "tg" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

# ---------------- LISTENER ----------------
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# ---------------- LAUNCH TEMPLATE ----------------
resource "aws_launch_template" "lt" {
  name_prefix   = "ramya-lt"
  image_id      = "ami-0f58b397bc5c1f2e8"
  instance_type = var.instance_type

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum install -y httpd
    echo "Hello from Auto Scaling EC2 🚀" > /var/www/html/index.html
    systemctl start httpd
    systemctl enable httpd
  EOF)

  vpc_security_group_ids = [aws_security_group.web_sg.id]
}

# ---------------- AUTO SCALING GROUP ----------------
resource "aws_autoscaling_group" "asg" {
  desired_capacity = 1
  max_size         = 2
  min_size         = 1

  vpc_zone_identifier = [aws_subnet.private.id]

  target_group_arns = [aws_lb_target_group.tg.arn]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
}
