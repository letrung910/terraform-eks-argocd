terraform {
  required_version = ">= 1.0.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = " >= 5.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

provider "aws" {
  region = var.region
  # shared_credentials_file = "path_file_credentials like C:\Users\terraform\.aws\credentials"
  profile = "default"
}

terraform {
  backend "s3" {
    bucket         = "trunglv-terrform-s3"
    key            = "dev/terraform.state"
    region         = var.region
    encrypt        = true
    dynamodb_table = "dev-dynamodb-lock"
  }
}
