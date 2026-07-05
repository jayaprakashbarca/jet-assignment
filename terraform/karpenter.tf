resource "aws_ec2_tag" "karpenter_cluster_sg_discovery" {
  resource_id = module.eks.cluster_security_group_id

  key   = "karpenter.sh/discovery"
  value = var.cluster_name
}

resource "helm_release" "karpenter" {
  name      = "karpenter"
  namespace = "kube-system"

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.karpenter_version

  wait    = true
  timeout = 600

  set = [
    {
      name  = "settings.clusterName"
      value = module.eks.cluster_name
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.iam.karpenter_controller_role_arn
      type  = "string"
    }
  ]

  depends_on = [
    module.eks,
    module.iam,
    aws_ec2_tag.karpenter_cluster_sg_discovery
  ]
}