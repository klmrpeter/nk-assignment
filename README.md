# nokia-assignment

###################################################################
ec2.tf
###################################################################

## Terraform AWS EC2 Auto Scaling Group Configuration

This Terraform configuration deploys an EC2 Auto Scaling Group in the AWS `eu-central-1` region using an Ubuntu AMI.

### AWS Provider Configuration

The `provider "aws"` block specifies the AWS region as `eu-central-1`.

### AWS Data Source for Latest Ubuntu AMI

The `data "aws_ami" "latest-ubuntu"` block retrieves the most recent Ubuntu AMI.

### AWS Launch Configuration

The resource `aws_launch_configuration.test` block defines a launch configuration. It uses the latest Ubuntu AMI retrieved from the data source. 
The instances have been deployed on private subnets, so i used `curl http://169.254.169.254/latest/meta-data/local-ipv4` to determine their IP adresses.
I used a random generated color code, to give every instance a unique background color.

### AWS Auto Scaling Group

The `resource "aws_autoscaling_group" "test"` block creates an Auto Scaling Group named "test". The group maintains a desired capacity of 2 instances, with a maximum and minimum size of 2. It uses the `aws_launch_configuration.test` launch configuration. The instances are distributed across `aws_subnet.private-1` and `aws_subnet.private-2` subnets. The Auto Scaling Group is associated with an AWS Elastic Load Balancing (ELB) target group using `aws_lb_target_group.test`. This ensures the load balancer directs traffic to these instances.

###################################################################
network.tf
###################################################################

## Terraform AWS VPC, Subnets, NatGateway, and Security Groups Configuration

This Terraform configuration sets up a VPC with public and private subnets, NAT gateway, and security groups in the AWS `eu-central-1` region.

### AWS VPC Configuration

The resource `aws_vpc.test` block creates a Virtual Private Cloud (VPC).

### AWS Subnet Configuration

Four subnets are created with different configurations:

- `aws_subnet.public-1` and `aws_subnet.public-2`: These are public subnets with public IP auto-mapping enabled.

- `aws_subnet.private-1` and `aws_subnet.private-2`: These are private subnets with public IP auto-mapping disabled. 

They are associated with Availability Zones defined by `var.az-1` and `var.az-2`.

### AWS NAT Gateway Configuration

An Elastic IP (`aws_eip.nat`) is created, which will be used for the NAT gateway. The `aws_nat_gateway.nat_gw` block sets up a NAT gateway using the allocated Elastic IP. It's associated with the `aws_subnet.public-1` subnet.

### AWS Route Tables Configuration

Two route tables are defined:

- `aws_route_table.private_route_table`: A route table for private subnets. The `aws_route.private_nat_gateway` block adds a route to the NAT gateway for internet access.

- `aws_route_table.public_route_table`: A route table for public subnets. The `aws_route.public_internet_gateway` block adds a route to the internet gateway for internet access.

### AWS Security Group Configuration

The resource `aws_security_group.test` allows incoming traffic on port 80 (HTTP). It also allows all outgoing traffic.

### AWS Security Group Rule Configuration

The resource `aws_security_group_rule.allow_http` block adds an ingress rule to the "test-sg" security group, allowing incoming HTTP traffic on port 80 from any source.

### AWS Load Balancer Configuration

An Application Load Balancer (ALB) named "test-lb" is created with public subnets. It's associated with the security group "test-sg". The ALB balances traffic across the defined public subnets.

### AWS Load Balancer Target Group Configuration

The resource `aws_lb_target_group.test` block defines a target group for the ALB. It's configured for HTTP on port 80 and associated with the VPC.

### AWS Load Balancer Listener Configuration

The resource `aws_lb_listener.test` block configures a listener on port 80 for the ALB. It forwards traffic to the defined target group.

###################################################################
Deploying
###################################################################

If you want to clone and run my solution, you need the following settings:

environments to add approve steps:
- DESTROY
- APPLY

secrets:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION