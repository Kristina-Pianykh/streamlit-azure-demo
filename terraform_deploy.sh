#!/usr/bin/env bash

export $(cat env | xargs)
ACR_NAME="${PROJECT_NAME}acr"
IMAGE_NAME="${PROJECT_NAME}-image"
export TF_VAR_image_name="${IMAGE_NAME}"
export TF_VAR_resource_group_location="${LOCATION}"

# terraform authentication with Azure
export TF_VAR_subscription_id="${ARM_SUBSCRIPTION_ID}"
export TF_VAR_client_id="${ARM_CLIENT_ID}"
export TF_VAR_client_secret="${ARM_CLIENT_SECRET}"
export TF_VAR_tenant_id="${ARM_TENANT_ID}"

terraform_deploy() {
    terraform -chdir=src/terraform init -upgrade \
    -backend-config="resource_group_name=$RESOURCE_GROUP" \
    -backend-config="storage_account_name=$STORAGE_ACCOUNT_NAME" \
    -backend-config="container_name=$CONTAINER_NAME" \
    -backend-config="key=terraform.tfstate"

    terraform -chdir=src/terraform plan -out=plan.out
    terraform -chdir=src/terraform apply plan.out
}

terraform_deploy

# if [ $? -eq 0 ]; then
#     echo "Docker images pushed successfully. Proceeding to terraform deploy..."
#     terraform_deploy
#     echo "Terraform deployment completed."
# else
#     echo "Docker image push failed. Exiting..."
#     exit 1
# fi
