variable "cluster_name" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "karpenter_node_role_arn" {
  description = "Existing EKS node IAM role ARN reused by Karpenter"
  type        = string
}