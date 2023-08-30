###################################################################
#VPC
###################################################################
resource "aws_vpc" "test" {
  cidr_block = var.vpc_ip_range
  tags = {
    Name = "test-vpc"
  }
}

###################################################################
# Subnets
###################################################################
resource "aws_subnet" "public-1" {
  vpc_id     = aws_vpc.test.id
  cidr_block = var.subnet_ip_range-1
  availability_zone = var.az-1
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-1"
  }
}

resource "aws_subnet" "public-2" {
  vpc_id     = aws_vpc.test.id
  cidr_block = var.subnet_ip_range-2
  availability_zone = var.az-2
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-2"
  }
}

resource "aws_subnet" "private-1" {
  vpc_id     = aws_vpc.test.id
  cidr_block = var.subnet_ip_range-3
  availability_zone = var.az-1
  map_public_ip_on_launch = false
  tags = {
    Name = "Private-1"
  }
}

resource "aws_subnet" "private-2" {
  vpc_id     = aws_vpc.test.id
  cidr_block = var.subnet_ip_range-4
  availability_zone = var.az-2
  map_public_ip_on_launch = false
  tags = {
    Name = "Private-2"
  }
}

###################################################################
# NatGateway
###################################################################
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-1.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.test.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id             = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "private_association_1" {
  subnet_id      = aws_subnet.private-1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_association_2" {
  subnet_id      = aws_subnet.private-2.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.test.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.test.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id         = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public_association_1" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_association_2" {
  subnet_id      = aws_subnet.public-2.id
  route_table_id = aws_route_table.public_route_table.id
}

###################################################################
# Security groups + rules
###################################################################

#Web
resource "aws_security_group" "test" {
  name        = "test-sg"
  description = "web-security-group"
  vpc_id      = aws_vpc.test.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_http" {
  type            = "ingress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test.id
}

resource "aws_lb" "test" {
  name               = "test-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.test.id]
  subnets            = [aws_subnet.public-1.id, aws_subnet.public-2.id]
  enable_cross_zone_load_balancing = true
  enable_deletion_protection = false
  enable_http2 = true
}

resource "aws_lb_target_group" "test" {
  name_prefix = "tg-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.test.id
}

resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.test.arn
  port              = 80

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}
