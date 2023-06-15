## backend
variable "tf_state_bucket" {
  type    = string
  default = "trunglv-terraform-workshop"
}

variable "tf_state_key" {
  type    = string
  default = "terraform.state"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "tf_state_table" {
  type    = string
  default = "dynamodb-lock"
}

## vpc
variable "environment_name" {
  type    = string
  default = "kgmmmmmm"
}
variable "vpc_name" {
  type    = string
  default = "vpc"
}

variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zone_names" {
  type    = list(string)
  default = ["us-east-1b", "us-east-1c"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.8.0/21", "10.0.16.0/21", "10.0.24.0/21"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.80.0/21", "10.0.88.0/21", "10.0.96.0/21"]
}

variable "intra_subnets" {
  type    = list(string)
  default = ["10.0.200.0/21", "10.0.208.0/21", "10.0.216.0/21"]
}


