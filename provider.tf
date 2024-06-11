data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_teste.eks_cluster.name
}

provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   =  module.eks_teste.endpoint
  cluster_ca_certificate = base64decode(module.eks_teste.certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_teste.endpoint
    cluster_ca_certificate = base64decode(module.eks_teste.certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

terraform {
  backend "s3" {
    bucket         = "terraform-stone-teste"
    key            = "eks/stone-teste.tfstate"
    dynamodb_table = "terraform-locks"
    region         = "us-east-1"
    encrypt        = true
  }
}