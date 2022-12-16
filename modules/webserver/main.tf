resource "aws_default_security_group" "default-sg"{
  vpc_id = var.vpc_id
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
resource "aws_key_pair" "ssh_key"{
  key_name ="server-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "dev-server"{
  ami = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh_key.key_name
  user_data = file("bootscript.sh")

   tags = {
    Name: "${var.env_prefix}-nginx-server"
  }
}