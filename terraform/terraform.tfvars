aws_region   = "us-east-1"
cluster_name = "jay-assignment"
eks_version  = "1.36"
vpc_cidr     = "10.0.0.0/16"

node_instance_types = ["t3.medium"]
node_desired_size   = 2
node_min_size       = 2
node_max_size       = 3

karpenter_version = "1.13.0"