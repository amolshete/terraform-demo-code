terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.33.0"
    }
  }


  backend "s3" {
    bucket = "terraform-webapp-demo"
    key    = "state"
    region = "ap-south-1"
  }
}


# Configure the AWS Provider
provider "aws" {
  region = var.REGION

}


# creating the VPC 

resource "aws_vpc" "demo-vpc" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Demo-VPC"
  }
}

# Creating the subnets

resource "aws_subnet" "mysubnet-1a" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "MY-SUBNET-1A"
  }
}

resource "aws_subnet" "mysubnet-1b" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.10.2.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "MY-SUBNET-1B"
  }
}

# Cerating Internet GW

resource "aws_internet_gateway" "Demo-IG" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "Demo-IG"
  }
}

# Creating the route table

resource "aws_route_table" "webapp-route-table" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Demo-IG.id
  }

  tags = {
    Name = "webapp-route-table"
  }
}

# Creating route table association

resource "aws_route_table_association" "webapp-RT-association-1A" {
  subnet_id      = aws_subnet.mysubnet-1a.id
  route_table_id = aws_route_table.webapp-route-table.id
}


resource "aws_route_table_association" "webapp-RT-association-1B" {
  subnet_id      = aws_subnet.mysubnet-1b.id
  route_table_id = aws_route_table.webapp-route-table.id
}

# creating target group for LB

resource "aws_lb_target_group" "webapp-LB-target-group" {
  name     = "webapp-LB-taget-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.demo-vpc.id
}

# Creating LB target group attachment

resource "aws_lb_target_group_attachment" "webapp-LB-target-group-attachment-1" {
  target_group_arn = aws_lb_target_group.webapp-LB-target-group.arn
  target_id        = aws_instance.Webapp-1.id
  port             = 80
}


resource "aws_lb_target_group_attachment" "webapp-LB-target-group-attachment-2" {
  target_group_arn = aws_lb_target_group.webapp-LB-target-group.arn
  target_id        = aws_instance.Webapp-2.id
  port             = 80
}


# Creating the load balancer

resource "aws_lb" "webapp-LB" {
  name               = "webapp-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_80-for-LB.id]
  subnets            = [aws_subnet.mysubnet-1a.id,aws_subnet.mysubnet-1b.id]

  # enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}


# Creating the listener

resource "aws_lb_listener" "webapp-LB-listener" {
  load_balancer_arn = aws_lb.webapp-LB.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp-LB-target-group.arn
  }
}



# Creating AWS autoscalling


resource "aws_launch_template" "webapp-launch-template" {
  name_prefix   = "webapp"
  image_id      = "ami-02fdd155a52f092f4"
  instance_type = "t2.micro"
  key_name = "linux-machine-on-aws-1"
  vpc_security_group_ids = [aws_security_group.allow_80_22.id]
}

resource "aws_autoscaling_group" "webapp-ASG" {
  # availability_zones = ["ap-south-1a","ap-south-1b"]
  desired_capacity   = 2
  max_size           = 3
  min_size           = 2
  vpc_zone_identifier = [aws_subnet.mysubnet-1a.id,aws_subnet.mysubnet-1b.id]

  launch_template {
    id      = aws_launch_template.webapp-launch-template.id
    version = "$Latest"
  }
}

# # Create a new ALB Target Group attachment
# resource "aws_autoscaling_attachment" "webapp-ASG-attachment" {
#   autoscaling_group_name = aws_autoscaling_group.webapp-ASG.id
#   lb_target_group_arn    = aws_lb_target_group.webapp-LB-target-group.arn
# }


# creating target group for LB

resource "aws_lb_target_group" "webapp-LB-target-group-2" {
  name     = "webapp-LB-taget-group-2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.demo-vpc.id
  
}



# Creating the load balancer

resource "aws_lb" "webapp-LB-2" {
  name               = "webapp-LB-2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_80-for-LB.id]
  subnets            = [aws_subnet.mysubnet-1a.id,aws_subnet.mysubnet-1b.id]

  # enable_deletion_protection = true

  tags = {
    Environment = "production-2"
  }
}


# Creating the listener

resource "aws_lb_listener" "webapp-LB-listener-2" {
  load_balancer_arn = aws_lb.webapp-LB-2.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp-LB-target-group-2.arn
  }
}



# Creating AWS autoscalling


resource "aws_launch_template" "webapp-launch-template-2" {
  name_prefix   = "webapp"
  image_id      = "ami-02fdd155a52f092f4"
  instance_type = "t2.micro"
  key_name = "linux-machine-on-aws-1"
  vpc_security_group_ids = [aws_security_group.allow_80_22.id]

}


resource "aws_autoscaling_group" "webapp-ASG-2" {
  # availability_zones = ["ap-south-1a","ap-south-1b"]
  desired_capacity   = 2
  max_size           = 3
  min_size           = 2
  vpc_zone_identifier = [aws_subnet.mysubnet-1a.id,aws_subnet.mysubnet-1b.id]

  target_group_arns = [aws_lb_target_group.webapp-LB-target-group-2.arn]

  launch_template {
    id      = aws_launch_template.webapp-launch-template-2.id
    version = "$Latest"
  }
}
