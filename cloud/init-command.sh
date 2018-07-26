#!/usr/bin/env bash
export TF_VAR_state_bucket_name=jakubbujny-article-form-your-cloud-1
export region="eu-central-1"
cd pre_init

terraform init
terraform apply -auto-approve

cd ..

cd network
terraform init -backend-config="bucket=${TF_VAR_state_bucket_name}" -backend-config="region=${region}"
cd ..

cd deployment
terraform init -backend-config="bucket=${TF_VAR_state_bucket_name}" -backend-config="region=${region}"
cd ..