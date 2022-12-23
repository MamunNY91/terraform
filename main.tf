provider "aws" {
  region = "us-east-1"
}


resource "aws_vpc" "custom-vpc"{
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}


resource "aws_subnet" "pub-subnet"{
  vpc_id = aws_vpc.custom-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags ={
    Name: "${var.env_prefix}-pub-subnet"
  }
}
resource "aws_internet_gateway" "custom-igw"{
  vpc_id = aws_vpc.custom-vpc.id
  tags ={
          Name: "${var.env_prefix}-IGW"
        }
}
resource "aws_route_table" "custom-rt"{
     vpc_id = aws_vpc.custom-vpc.id
     route{
        #route for internal traffic is created automsatically.
        #we have to create route for IGW
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.custom-igw.id
       
     }
      tags ={
          Name: "${var.env_prefix}-RT"
        }
}
resource "aws_route_table_association" "custom-rt-sub-association" {
  subnet_id      = aws_subnet.pub-subnet.id
  route_table_id = aws_route_table.custom-rt.id
}
#set custom-rt as main rt for custom vpc
resource "aws_main_route_table_association" "a-custom-rt-vpc" {
  vpc_id = aws_vpc.custom-vpc.id
  route_table_id = aws_route_table.custom-rt.id
}

/*
   a default SG is created when you create VPC lets modify default one.
   execute terraform state list to see list of resources
   execute terraform state show aws_vpc.custom-vpc   to see
   attributes of vpc. we are gonna modify default SG
*/
resource "aws_default_security_group" "default-sg"{
  vpc_id = aws_vpc.custom-vpc.id
  ingress {
      from_port = 22
      to_port   = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
      from_port = 8080
      to_port   = 8080
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  # for outgoing traffic . 
  #for ex- sending request from our server to fetch docker imgage, update package etc
  egress{
      from_port = 0
      to_port   = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      prefix_list_ids = [] # allowing access to VPC endpoints
  }
  tags = {
    Name: "${var.env_prefix}-default-SG"
  }
}

#get the latest AMI
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
 
}
resource "aws_instance" "dev-server"{
  ami = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.pub-subnet.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = "testInstance"
  user_data = file("bootscript.sh")
   tags = {
    Name: "${var.env_prefix}-nginx-server"
  }
}
resource "aws_instance" "dev-server2"{
  ami = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.pub-subnet.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = "testInstance"
  user_data = file("bootscript.sh")
   tags = {
    Name: "${var.env_prefix}-nginx-server2"
  }
}
resource "aws_instance" "dev-server3"{
  ami = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.pub-subnet.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = "testInstance"
  user_data = file("bootscript.sh")
   tags = {
    Name: "${var.env_prefix}-nginx-server3"
  }
}



/*

data "aws_vpc" "existing_vpc"{
  default = true

}
resource "aws_subnet" "dev-subnet2"{
  vpc_id = data.aws_vpc.existing_vpc.id
  cidr_block = "172.31.128.0/20"
}


resource "aws_instance" "dev-server"{
  ami = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.pub-subnet.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = "testInstance"
  user_data = <<EOF
                  #!/bin/bash
                  sudo yum update -y 
                  sudo yum install docker -y
                  sudo systemctl start docker
                  sudo systemctl enable docker
                  sudo usermod -aG docker ec2-user
                  sudo reboot
                  docker run -p 8080:80 nginx
              EOF
   tags = {
    Name: "${var.env_prefix}-nginx-server"
  }
}

*/
