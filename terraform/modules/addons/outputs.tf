output "ebs_csi_addon_name" {
  description = "EBS CSI add-on name"
  value       = aws_eks_addon.ebs_csi.addon_name
}