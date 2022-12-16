provider "aws" {}

//reference module in this config file
//now we can provide values for variables defined in the module
//we r referencing a variable defined at root level
module "custom-subnet" {
  source = "./modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.custom-vpc.id
  default_route_table_id = aws_vpc.custom-vpc.default_route_table_id
}

resource "aws_vpc" "custom-vpc"{
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}
module "webserver" {
  source = "./modules/webserver"
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.custom-vpc.id
  public_key_location = var.public_key_location
  instance_type = var.instance_type
  subnet_id = module.custom-subnet.subnet.id
}



/*
   a default SG is created when you create VPC lets modify default one.
   execute terraform state list to see list of resources
   execute terraform state show aws_vpc.custom-vpc   to see
   attributes of vpc. we are gonna modify default SG
*/





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

resource "aws_instance" "dev-server"{
  ami = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.pub-subnet.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh_key.key_name
  #user_data = file("bootscript.sh")
  connection{
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file(var.private_key_location)

  }
  provisioner "remote-exec" {
      inline =[
        "export ENV = staging",
        "touch file.txt"
      ]
  }


   tags = {
    Name: "${var.env_prefix}-nginx-server"
  }
}




*/
