#!/usr/bin/env bash
export TF_VAR_state_bucket_name=jakubbujny-article-form-your-cloud-1

cd pre_init

terraform init
terraform apply -auto-approve

cd ..

terraform init -backend-config="bucket=${TF_VAR_state_bucket_name}" -backend-config="region=eu-central-1"