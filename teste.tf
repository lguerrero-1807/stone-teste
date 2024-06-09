locals {
  cluster_name  = "stone_teste"
  aws_region    = "us-east-1"
  k8s_version   = "1.30"
}

data "aws_vpc" "cluster-vpc" {
  depends_on = [module.network_teste]
  tags = {
    Name  = "stone_teste-vpc"
  }
}

data "aws_subnet" "private-1a"{
  depends_on = [module.network_teste]
  tags = {
    Name  = "stone_teste-private-1a"
  }
}

data "aws_subnet" "private-1c"{
  depends_on = [module.network_teste]
  tags = {
    Name  = "stone_teste-private-1c"
  }
}

data "aws_security_group" "eks-sg" {
  depends_on = [module.eks_teste]
  tags = {
    Name  = "stone_teste-master-sg"
  }
}

module "network_teste" {
  source = "git::https://github.com/lguerrero-1807/blueprint-modules.git//network"

  cluster_name  = local.cluster_name
  aws_region    = local.aws_region
}

module "eks_teste" {
  depends_on = [module.network_teste]
  source = "git::https://github.com/lguerrero-1807/blueprint-modules.git//eks"

  cluster_name      = local.cluster_name
  aws_region        = local.aws_region
  k8s_version       = local.k8s_version
  cluster_vpc       = data.aws_vpc.cluster-vpc
  private_subnet_1a = data.aws_subnet.private-1a
  private_subnet_1c = data.aws_subnet.private-1c
}


module "nodes_teste" {
  source = "git::https://github.com/lguerrero-1807/blueprint-modules.git//nodes"

  cluster_name          = local.cluster_name
  aws_region            = "us-east-1"
  k8s_version           = local.k8s_version
  cluster_vpc           = data.aws_vpc.cluster-vpc
  private_subnet_1a     = data.aws_subnet.private-1a
  private_subnet_1c     = data.aws_subnet.private-1c
  eks_cluster           = local.cluster_name
  eks_cluster_sg        = data.aws_security_group.eks-sg
  #Mudar este nome de variavel para instace_type
  nodes_instances_sizes = ["t3a.micro"]
  auto_scale_options    = {
    desired = 1
    min     = 1
    max     = 3
  }
  auto_scale_cpu = {
    scale_up_cooldown     = 300
    scale_up_add          = 1
    scale_up_evaluation   = 1
    scale_up_period       = 300
    scale_up_threshold    = 60
    scale_down_cooldown   = 300
    scale_down_remove     = -1
    scale_down_evaluation = 1
    scale_down_period     = 300
    scale_down_threshold  = 40
  }
}
