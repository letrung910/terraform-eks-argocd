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
TF_OPTS2=${5}
TF_OPTS3=${6}
TF_VAR_ENVIRONMENT=${ENVIRONMENT:-dev}
TF_VAR_region=${region:-us-east-1}

cat <<EOF > ${CHDIR}/backend.tf
terraform {
backend "s3" {
    bucket         = "trunglv-terraform-workshop"
    key            = "${ENVIRONMENT}/${CHDIR}/terraform.tfstate"
    region         = "${TF_VAR_region}"
    encrypt        = true
    dynamodb_table = "${ENVIRONMENT}-dynamodb-lock"
}
}
EOF

terraform -chdir=${CHDIR} ${TF_COMMAND} -var-file="${ENVIRONMENT}.tfvars" ${TF_OPTS} ${TF_OPTS2} ${TF_OPTS3}
