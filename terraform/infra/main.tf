terraform {
  required_version = ">= 1.0.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = " >= 5.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.17"
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
  region = "us-east-1"
  # shared_credentials_file = "path_file_credentials like C:\Users\terraform\.aws\credentials"
}

terraform {
  backend "s3" {
    bucket         = "trunglv-terraform-workshop"
    key            = "dev/terraform.state"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "dev-dynamodb-lock"
  }
}
