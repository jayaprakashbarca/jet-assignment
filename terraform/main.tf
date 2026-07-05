module "vpc" {
  source = "./modules/vpc"

  cluster_name = var.cluster_name
  vpc_cidr     = var.vpc_cidr
}

module "eks" {
  source = "./modules/eks"

  cluster_name        = var.cluster_name
  eks_version         = var.eks_version
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids   = module.vpc.public_subnet_ids
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
}

module "iam" {
  source = "./modules/iam"

  cluster_name      = var.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

  karpenter_node_role_arn = module.eks.node_role_arn
}

module "addons" {
  source = "./modules/addons"

  cluster_name     = module.eks.cluster_name
  ebs_csi_role_arn = module.iam.ebs_csi_irsa_role_arn

  depends_on = [
    module.eks,
    module.iam
  ]
}