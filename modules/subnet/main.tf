/*
if a resource that is referencing another resource which exist in this 
file, then we dont need to use variable


*/

resource "aws_subnet" "pub-subnet"{
  vpc_id = var.vpc_id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone

  tags ={
    Name: "${var.env_prefix}-pub-subnet"
  }
}
resource "aws_internet_gateway" "custom-igw"{
  vpc_id = var.vpc_id
  tags ={
          Name: "${var.env_prefix}-IGW"
        }
}
resource "aws_default_route_table" "main-rtb" {
    default_route_table_id = var.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.custom-igw.id
    }
    tags = {
        Name = "${var.env_prefix}-main-rtb"
    }
}
resource "aws_route_table_association" "default-rt" {
  subnet_id      = aws_subnet.pub-subnet.id
  route_table_id = aws_default_route_table.main-rtb.id
}
