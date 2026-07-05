output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "backend_irsa_role_arn" {
  value = module.iam.backend_irsa_role_arn
}

output "ebs_csi_irsa_role_arn" {
  description = "EBS CSI Driver IAM Role ARN"
  value       = module.iam.ebs_csi_irsa_role_arn
}

output "ebs_csi_addon_name" {
  description = "EBS CSI EKS add-on name"
  value       = module.addons.ebs_csi_addon_name
}