
# Creating the EC2


resource "aws_security_group" "allow_80_22" {
  name        = "allow_port-80-and-port-22"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.demo-vpc.id

  ingress {
    description      = "Allow port 22"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0","1.186.119.156/32"]
  }

  ingress {
    description      = "Allow port 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0","1.186.119.156/32"]
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_22-80"
  }
}


# creating SG for LB

resource "aws_security_group" "allow_80-for-LB" {
  name        = "allow_port-80"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.demo-vpc.id

  
  ingress {
    description      = "Allow port 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-80"
  }
}

