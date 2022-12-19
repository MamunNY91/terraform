provider "aws"{
    region = "us-east-1"
}
variable vpc_cidr_block{}
variable private_subnet_cidr_blocks{}
variable public_subnet_cidr_blocks{}
data "aws_availability_zones" "azs"{

}
module "custom-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"
  name = "custom-vpc"
  cidr = var.vpc_cidr_block
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets = var.public_subnet_cidr_blocks
  azs = data.aws_availability_zones.azs.names
  enable_nat_gateway = true
  # 1 single shared natgateway for all private subnet
  single_nat_gateway = true 
  enable_dns_hostnames = true
  /*
  these tags are needed for
   Control Plane to identify VPC and subnets.

  
  */
  tags = {
    "kubernetes.io/cluster/my-eks-cluster"="shared"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}


