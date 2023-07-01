#!/bin/bash
### example
### export ENVIRONMENT="dev"

### ./terraform.sh $ENVIRONMENT networking init
### ./terraform.sh $ENVIRONMENT networking plan
### ./terraform.sh $ENVIRONMENT networking apply --auto-approve

ENVIRONMENT=${1}
CHDIR=${2}
TF_COMMAND=${3}
TF_OPTS=${4}

TF_VAR_ENVIRONMENT=${ENVIRONMENT:-dev}
TF_VAR_region=${region:-us-east-1}

cat <<EOF > ${CHDIR}/backend.tf
terraform {
backend "s3" {
    bucket         = "trunglv-terraform-workshop"
    key            = "${ENVIRONMENT}/${CHDIR}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "${ENVIRONMENT}-dynamodb-lock"
}
}
EOF

terraform -chdir=${CHDIR} ${TF_COMMAND} -var-file="${ENVIRONMENT}.tfvars" ${TF_OPTS}
