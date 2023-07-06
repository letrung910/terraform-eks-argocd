resource "aws_iam_user" "eks_user" {
  name = "eks_user"
}

data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

# Create an IAM role
resource "aws_iam_role" "eks_role" {
  name = "eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the IAM policy to the IAM role
resource "aws_iam_policy_attachment" "eks_role_policy_attachment" {
  name = "Policy Attachement"
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ])
  roles      = [aws_iam_role.eks_role.name]
  policy_arn = each.value
  users      = [aws_iam_user.eks_user.name]
}



module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = module.env.eks_name
  cluster_version = module.env.cluster_version

  cluster_endpoint_public_access = true
  cluster_addons = {
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
    }

    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }

    coredns = {
      resolve_conflicts = "OVERWRITE"
      configuration_values = jsonencode({
        # computeType = "Fargate"
        # Ensure that we fully utilize the minimum amount of resources that are supplied by
        # Fargate https://docs.aws.amazon.com/eks/latest/userguide/fargate-pod-configuration.html
        # Fargate adds 256 MB to each pod's memory reservation for the required Kubernetes
        # components (kubelet, kube-proxy, and containerd). Fargate rounds up to the following
        # compute configuration that most closely matches the sum of vCPU and memory requests in
        # order to ensure pods always have the resources that they need to run.
        resources = {
          limits = {
            cpu = "0.25"
            # We are targeting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
          requests = {
            cpu = "0.25"
            # We are targeting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
        }
      })
    }
  }


  vpc_id                   = data.terraform_remote_state.networking.outputs.vpc_id
  subnet_ids               = data.terraform_remote_state.networking.outputs.private_subnets
  control_plane_subnet_ids = data.terraform_remote_state.networking.outputs.intra_subnets

  # # Self Managed Node Group(s)
  # self_managed_node_group_defaults = {
  #   instance_type                          = "t3.micro"
  #   update_launch_template_default_version = true
  #   iam_role_additional_policies = {
  #     AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  #   }
  # }

  # self_managed_node_groups = {
  #   one = {
  #     name         = "mixed-1"
  #     max_size     = 5
  #     desired_size = 2

  #     use_mixed_instances_policy = true
  #     mixed_instances_policy = {
  #       instances_distribution = {
  #         on_demand_base_capacity                  = 0
  #         on_demand_percentage_above_base_capacity = 10
  #         spot_allocation_strategy                 = "capacity-optimized"
  #       }

  #       override = [
  #         {
  #           instance_type     = "t3.micro"
  #           weighted_capacity = "1"
  #         },
  #         {
  #           instance_type     = "t2.micro"
  #           weighted_capacity = "2"
  #         },
  #       ]
  #     }
  #   }
  # }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t3.micro"]
  }

  eks_managed_node_groups = {
    blue = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT" ### Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT
      labels = merge(module.env.tags, {
        # NOTE - if creating multiple security groups with this module, only tag the
        # security group that Karpenter should utilize with the following tag
        # (i.e. - at most, only one security group should have this tag in your account)
        nodegroup   = "blue"
        "Terraform" = "True"
      })
    }
    green = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT" ### Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT
      labels = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
        nodegroup   = "green"
      }
      update_config = {
        max_unavailable_percentage = 33 # or set `max_unavailable`
      }
      ebs_optimized     = true
      enable_monitoring = true
    }
    gpu = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT" ### Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT
      labels = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
        nodegroup   = "gpu"
      }
      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      }
      update_config = {
        max_unavailable_percentage = 33 # or set `max_unavailable`
      }
      ebs_optimized     = true
      enable_monitoring = true
    }
  }

  # Fargate Profile(s)
  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
        }
      ]
    }
  }






  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    # We need to add in the Karpenter node IAM role for nodes launched by Karpenter
    {
      rolearn  = module.karpenter.role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
    {
      rolearn  = "${aws_iam_role.eks_role.arn}"
      username = "role1"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_users = [
    {
      userarn  = "${aws_iam_user.eks_user.arn}"
      username = "eks_user"
      groups   = ["system:masters"]
    },
    # {
    #   userarn  = "arn:aws:iam::66666666666:user/user2"
    #   username = "user2"
    #   groups   = ["system:masters"]
    # },
  ]

  #   aws_auth_accounts = [
  #     "777777777777",
  #     "888888888888",
  #   ]

  tags = merge(module.env.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = module.env.eks_name
    "Terraform"              = "True"
  })
}

### karpenter
module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name           = module.eks.cluster_name
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = merge(module.env.tags, {
    "Terraform" = "True"
  })
}

resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = "v0.21.1"

  set {
    name  = "settings.aws.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "settings.aws.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.irsa_arn
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = module.karpenter.instance_profile_name
  }

  set {
    name  = "settings.aws.interruptionQueueName"
    value = module.karpenter.queue_name
  }
}

resource "kubectl_manifest" "karpenter_provisioner" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1alpha5
    kind: Provisioner
    metadata:
      name: default
    spec:
      requirements:
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot"]
        - key: karpenter.k8s.aws/instance-size
          operator: In
          values: [medium, large]
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["t"]
      limits:
        resources:
          cpu: 100
      providerRef:
        name: default
      ttlSecondsAfterEmpty: 30
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_node_template" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1alpha1
    kind: AWSNodeTemplate
    metadata:
      name: default
    spec:
      subnetSelector:
        karpenter.sh/discovery: ${module.eks.cluster_name}
      securityGroupSelector:
        karpenter.sh/discovery: ${module.eks.cluster_name}
      tags:
        karpenter.sh/discovery: ${module.eks.cluster_name}
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

# Example deployment using the [pause image](https://www.ianlewis.org/en/almighty-pause-container)
# and starts with zero replicas
resource "kubectl_manifest" "karpenter_example_deployment" {
  yaml_body = <<-YAML
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: inflate
    spec:
      replicas: 0
      selector:
        matchLabels:
          app: inflate
      template:
        metadata:
          labels:
            app: inflate
        spec:
          terminationGracePeriodSeconds: 0
          containers:
            - name: inflate
              image: public.ecr.aws/eks-distro/kubernetes/pause:3.7
              resources:
                requests:
                  cpu: 1
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

### eks addons
module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  enable_aws_load_balancer_controller = true
  # enable_cluster_proportional_autoscaler = true
  enable_cluster_autoscaler    = true # work with EKS Managed Node Group(s) ASG
  enable_kube_prometheus_stack = true
  enable_metrics_server        = true
  # enable_argo_rollouts                = true
  # enable_argocd                       = true
  # enable_ingress_nginx                = true

  # enable_external_dns                    = true
  # enable_cert_manager                    = true
  # cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/XXXXXXXXXXXXX"]

  tags = merge(module.env.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "Terraform" = "True"
  })
}

resource "kubernetes_namespace" "environment" {
  metadata {
    name = var.environment
  }
}

