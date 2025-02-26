provider "kubernetes" {
    host = data.aws_eks_cluster.myapp-cluster.endpoint
    token = data.aws_eks_cluster_auth.myapp-cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.myapp-cluster.certificate_authority.0.data)
}

data "aws_eks_cluster" "myapp-cluster" {
    name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "myapp-cluster" {
    name = module.eks.cluster_name
}

output "cluster_id" {
  value = module.eks.cluster_name
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.33.1"

    cluster_name = "myapp-eks-cluster"
    cluster_version = "1.31"
    
    subnet_ids = module.myapp-vpc.private_subnets
    vpc_id = module.myapp-vpc.vpc_id

    tags = {
        environment = "dev"
        application = "myapp"
    }
    
    eks_managed_node_groups = {
        worker-group-1 = {
            instance_types = ["t2.small"]
            min_size       = 1
            max_size       = 3
            desired_size   = 2
  }
        worker-group-2 = {
            instance_types = ["t2.medium"]
            min_size       = 1
            max_size       = 2
            desired_size   = 1
  }
}
}