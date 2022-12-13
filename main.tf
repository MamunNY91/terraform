provider "aws" {
  region = "us-east-1"
 
}

resource "aws_vpc" "dev-vpc"{
  cidr_block = "10.10.0.0/16"
  tags = {
    Name: "dev-vpc"
  }
}
variable "subnet_cidr_block"{
  description = "subnet cidr block"
}




resource "aws_subnet" "dev-subnet-1"{
  vpc_id = aws_vpc.dev-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = "us-east-1a"
  tags ={
    Name: "dev-subnet01"
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

*/
output "dev-vpc-id"{
  value = aws_vpc.dev-vpc.id
}