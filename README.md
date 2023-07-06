# demo for workshop
This is demo for workshop
## Workshop have 3 repos

* [Infrastructure](https://github.com/letrung910/terraform-eks-argocds)

  - Terraform: deploy AWS VPC + EKS + Serverless
  - EKS - add ons: Karpenter + ArgoCD + Keda

* [Gitops](https://github.com/letrung910/application-gitops-argocd)

  - GitOps Repo include Dockerfile + k8s kustomize manifest

* [monorepo](https://github.com/letrung910/monorepo)
  - app1
  - app2

## Stack in this repo
```
Cloud: AWS
IaC: Terraform
CI/CD:
	+ GithubAction for Application
	+ Atlantis for Terraform IaC
Container: Kubernetes EKS
Manage Kubernetes applications: Kustomize, Helm
Autoscale node: Karpenter
HPA : Keda
GitOps: ArgoCD
```

