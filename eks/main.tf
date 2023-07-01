module "envs" {
  source      = "../modules/envs"
  environment = "${var.environment}"
  project     = "${var.project}"

}