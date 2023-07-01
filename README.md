## usng variable for backend
```hcl
terraform {
  backend "s3" {}
}

data "terraform_remote_state" "state" {
  backend = "s3"
  config {
    bucket     = "${var.tf_state_bucket}"
    key        = "${var.environment}/${var.tf_state_key}"
    dynamodb_table = "${var.environment}-${var.tf_state_table}"
    region     = "${var.region}"
  }
}
```

## run terraform init dev env

```bash
TF_VAR_tf_state_bucket=trunglv-terraform-workshop \
TF_VAR_environment=dev \
TF_VAR_tf_state_key=terraform.state \
TF_VAR_tf_state_table=dynamodb-lock \
TF_VAR_region=us-east-1
```
## run terraform init test env
TF_VAR_tf_state_bucket=trunglv-terraform-workshop \
TF_VAR_environment=test \
TF_VAR_tf_state_key=terraform.state \
TF_VAR_tf_state_table=dynamodb-lock \
TF_VAR_region=us-east-1

```
terraform init \
     -backend-config "bucket=$TF_VAR_tf_state_bucket" \
     -backend-config "key=$TF_VAR_environment/$TF_VAR_tf_state_key" \
     -backend-config "dynamodb_table=$TF_VAR_environment-$TF_VAR_tf_state_table" \
     -backend-config "region=$TF_VAR_region"
```
### plan
terraform plan -var-file="env/dev.tfvars"
terraform plan -var-file="env/test.tfvars"
terraform plan -out output.plan
terraform show -no-color output.plan 2>&1 > plan.txt
terraform force-unlock 928e7c25-4c0b-0be2-ced9-4fe70a9174ea
### eks https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples
aws eks update-kubeconfig --region us-east-1 --name workshop-dev-cluster --profile dev
kubectl describe -n kube-system configmap/aws-auth

### export ENVIRONMENT="dev"

### ./terraform.sh $ENVIRONMENT networking init
### ./terraform.sh $ENVIRONMENT networking plan
### ./terraform.sh $ENVIRONMENT networking apply --auto-approve