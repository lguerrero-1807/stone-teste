locals {
  cluster_name  = "stone_teste"
  aws_region    = "us-east-1"
  k8s_version   = "1.30"
  cidr_block    = "10.0.0.0/16"
}

module "network_teste" {
  source = "git::https://github.com/lguerrero-1807/blueprint-modules.git//network"

  cluster_name                = local.cluster_name
  aws_region                  = local.aws_region
  cidr_block                  = local.cidr_block
  private_subnet_cidr_blocks  = ["10.0.32.0/20", "10.0.48.0/20"]
  public_subnet_cidr_blocks   = ["10.0.0.0/20", "10.0.16.0/20"]
  availability_zones          = ["us-east-1a", "us-east-1c"]
}

module "eks_teste" {
  depends_on = [module.network_teste]
  source = "git::https://github.com/lguerrero-1807/blueprint-modules.git//eks"

  cluster_name            = local.cluster_name
  aws_region              = local.aws_region
  k8s_version             = local.k8s_version
  cluster_vpc             = module.network_teste.cluster_vpc
  private_subnet_ids      = module.network_teste.private_subnets
}


module "nodes_teste" {
  depends_on = [module.network_teste, module.eks_teste]
  source = "git::https://github.com/lguerrero-1807/blueprint-modules.git//nodes"

  cluster_name            = local.cluster_name
  aws_region              = local.aws_region
  k8s_version             = local.k8s_version
  cluster_vpc             = module.network_teste.cluster_vpc
  private_subnet_ids      = module.network_teste.private_subnets
  nodes_instances_types   = ["t3a.small"]
  auto_scale_options      = {
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

module "ingress_nginx" {
  source                     = "./helm_ingress_nginx"
  depends_on                 = [module.eks_teste]
  endpoint                   = module.eks_teste.endpoint
  certificate_authority_data = module.eks_teste.certificate_authority_data
  token                      = data.aws_eks_cluster_auth.cluster.token
  public_subnet_ids          = module.network_teste.public_subnets
}
