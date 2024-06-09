module "meu_modulo" {
  source = "git::https://github.com/lguerrero-1807/blueprint-modules.git//network"

  cluster_name  = "stone_teste"
  aws_region    = "us-east-1"
}
