data "aws_caller_identity" "current" {}
locals {
  eks_name   = "${var.environment_name}-cluster"
  cluster_version = "1.27"
  region = "eu-west-1"

  azs      = slice(data.aws_availability_zones.available.names, 0, 2)
  tags = {
    Example    = local.eks_name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
  common_tags = {
    DeployedBy  = "trunglv"
    Application = "homelab"
    Environment = var.environment_name
  }
  account_id = data.aws_caller_identity.current.account_id
}

locals {

}
