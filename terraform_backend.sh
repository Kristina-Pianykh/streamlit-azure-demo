#!/usr/bin/env bash

# Run to initialize the backend for storing terraform state file:
# ./terraform_backend.sh env

path=$1

if [! -f "$path"]; then
   echo "ERROR: $path does not exist. Provide a valid file name with environment variables."
   exit 1
fi

export $(cat $path | xargs)

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME
