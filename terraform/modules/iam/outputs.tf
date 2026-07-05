output "backend_irsa_role_arn" {
  value = aws_iam_role.backend_irsa.arn
}

output "ebs_csi_irsa_role_arn" {
  description = "IAM role ARN for EBS CSI Driver"
  value       = aws_iam_role.ebs_csi_irsa.arn
}

output "karpenter_controller_role_arn" {
  description = "IAM role ARN for Karpenter controller"
  value       = aws_iam_role.karpenter_controller.arn
}