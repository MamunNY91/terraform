provider "kubernetes"{
   
}


locals {
  cluster_name = "my-eks-cluster"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.1.0"
  cluster_name = "${local.cluster_name}"
  cluster_version = "1.23"
  vpc_id = module.custom-vpc.vpc_id
  subnet_ids = module.custom-vpc.private_subnets
  cluster_endpoint_public_access = true
  tags = {
    environment = "development"
    application = "myapp"
  }
   eks_managed_node_groups = {
    dev = {
      min_size     = 1
      max_size     = 3
      desired_size = 3

      instance_types = ["t2.small"]
    }
  }


}

/*
provider "kubernetes"{
  /*
  # we are not gonna use local 
  kubeconfig file that's why we r 
  making it false
  

  #provide api server endpoint of the master node
  host = data.aws_eks_cluster.my-cluster.endpoint
  token = data.aws_eks_cluster_auth.my-cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.my-cluster.certificate_authority.0.data)
  
}
#query on aws_eks_cluster with name of the id , returns eks_cluster object
data "aws_eks_cluster" "my-cluster"{
  name= module.eks.cluster_id
}
data "aws_eks_cluster_auth" "my-cluster"{
  name= module.eks.cluster_id
}

output "showEndpoint" {
  value = data.aws_eks_cluster.my-cluster.endpoint
}
*/