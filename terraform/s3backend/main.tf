terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 5.0.0"

    }
  }
}

provider "aws" {
  region                  = "us-west-1"
  profile                 = "dev"
}

resource "aws_s3_bucket" "terraform" {
  bucket = "trunglv-terrform-s3"
}
resource "aws_s3_bucket_acl" "terraform_bucket_acl" {
  bucket = aws_s3_bucket.terraform.id
  acl    = "private"
}
resource "aws_s3_bucket_versioning" "versioning_terraform" {
  bucket = aws_s3_bucket.terraform.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.terraform.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_dynamodb_table" "dev-dynamodb-lock" {
  name           = "dev-dynamodb-lock"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "dev-dynamodb-lock"
    Environment = "dev"
  }
}
