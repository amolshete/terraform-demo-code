
resource "aws_instance" "Webapp-1" {
  ami           = "ami-062df10d14676e201"
  key_name      = "linux-machine-on-aws-1"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.mysubnet-1a.id
  vpc_security_group_ids = [aws_security_group.allow_80_22.id]
  # security_groups = ["security_demo_port"]
  tags = {
    Name            = "Webapp-1"
    App             = "frontend"
    Technical-Owner = "Amol"
  }

}


resource "aws_instance" "Webapp-2" {
  ami           = "ami-062df10d14676e201"
  key_name      = "linux-machine-on-aws-1"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.mysubnet-1b.id
  vpc_security_group_ids = [aws_security_group.allow_80_22.id]
  # security_groups = ["security_demo_port"]
  tags = {
    Name            = "Webapp-2"
    App             = "frontend"
    Technical-Owner = "Amol"
  }

}
