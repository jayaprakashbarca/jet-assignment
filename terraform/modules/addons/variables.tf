variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "ebs_csi_role_arn" {
  description = "IAM role ARN used by EBS CSI controller"
  type        = string
}