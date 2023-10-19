#!/usr/bin/env bash

export $(cat env | xargs)
ACR_NAME="${PROJECT_NAME}acr"
IMAGE_NAME="${PROJECT_NAME}-image"

terraform -chdir=src/terraform init \
 -backend-config="resource_group_name=$RESOURCE_GROUP" \
 -backend-config="storage_account_name=$STORAGE_ACCOUNT_NAME" \
 -backend-config="container_name=$CONTAINER_NAME" \
 -backend-config="key=terraform.tfstate"

terraform -chdir=src/terraform plan -out=plan.out
terraform -chdir=src/terraform apply plan.out

docker image build -t $IMAGE_NAME .
docker tag $IMAGE_NAME streamlittoyappacr.azurecr.io/$IMAGE_NAME
az acr login --name $ACR_NAME
docker push streamlittoyappacr.azurecr.io/$IMAGE_NAME
