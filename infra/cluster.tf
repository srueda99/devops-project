# --- EKS USER ---

resource "aws_iam_user" "admin_eks" {
  name = "admin-eks"
  path = "/"
}

resource "aws_iam_access_key" "admin_eks_keys" {
  user = aws_iam_user.admin_eks.name
}

# --- EKS CLUSTER ---

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> 20.0"
  cluster_name                    = "devops-cluster"
  cluster_version                 = "1.29"
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  vpc_id                          = aws_vpc.main_vpc.id
  subnet_ids                      = [aws_subnet.priv_subnet_1.id, aws_subnet.priv_subnet_2.id]
  eks_managed_node_groups = {
    cluster_nodes = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.medium", "t3.large"]
      capacity_type  = "SPOT"
    }
  }
  enable_cluster_creator_admin_permissions = true
  access_entries = {
    admin_eks_access = {
      principal_arn = aws_iam_user.admin_eks.arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
  tags = {
    "Name"    = "devops-cluster"
    "Project" = "devops"
  }
}

# --- OUTPUTS ---

output "cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.eks.cluster_endpoint
}

output "admin_eks_access_key" {
  description = "EKS Admin Access Key"
  value       = aws_iam_access_key.admin_eks_keys.id
  sensitive   = false
}

output "admin_eks_secret_key" {
  description = "EKS Admin Secret Key"
  value       = aws_iam_access_key.admin_eks_keys.secret
  sensitive   = true
}
