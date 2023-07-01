data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "trunglv-terraform-workshop"
    key    = "${var.environment}/networking/terraform.tfstate"
    region = "us-east-1"
  }
}

