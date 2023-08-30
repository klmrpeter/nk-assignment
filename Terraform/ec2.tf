provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "latest-ubuntu" {
most_recent = true
owners = ["099720109477"] # Canonical

  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

###################################################################
# EC2 config
###################################################################

resource "aws_launch_configuration" "test" {
  name_prefix = "test-"
  image_id           = data.aws_ami.latest-ubuntu.id
  instance_type      = "t2.micro"
  security_groups   = [aws_security_group.test.id]
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              echo "<html><body style=\"background-color:#$(printf "%02X" $((RANDOM % 256)))$(printf "%02X" $((RANDOM % 256)))$(printf "%02X" $((RANDOM % 256)))\"><h1>Instance IP: $(curl http://169.254.169.254/latest/meta-data/local-ipv4)</h1></body></html>" | tee /var/www/html/index.html
              service nginx start
              EOF
}

resource "aws_autoscaling_group" "test" {
  name                 = "test"
  max_size             = 2
  min_size             = 2
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.test.name
  vpc_zone_identifier = [aws_subnet.private-1.id, aws_subnet.private-2.id]
  target_group_arns = [aws_lb_target_group.test.arn]
}