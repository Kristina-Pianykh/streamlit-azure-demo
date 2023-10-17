#!/usr/bin/env bash

terraform -chdir=src/terraform init \
 -backend-config="resource_group_name=rg-streamlit-test" \
 -backend-config="storage_account_name=tfstate2755" \
 -backend-config="container_name=tfstate" \
 -backend-config="key=terraform.tfstate"

terraform -chdir=src/terraform plan -out=plan.out
terraform -chdir=src/terraform apply plan.out
