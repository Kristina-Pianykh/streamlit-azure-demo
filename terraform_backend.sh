#!/usr/bin/env bash

# Run to initialize the backend for storing terraform state file:
# ./terraform_backend.sh env

path=$1

if [! -f "$path"]; then
   echo "ERROR: $path does not exist. Provide a valid file name with environment variables."
   exit 1
fi

export $(cat $path | xargs)

# check if resource group exists and create if not
if [ $(az group exists --name $RESOURCE_GROUP) = false ]; then
    echo "Resource group $RESOURCE_GROUP does not exist. Creating..."
    az group create --name $RESOURCE_GROUP --location $LOCATION
    GROUP_ID=$(az group show --name $RESOURCE_GROUP --query id --output tsv)
    echo "Resource group $RESOURCE_GROUP created."
else
    echo "Resource group $RESOURCE_GROUP already exists."
fi

# check if storage account exists and create if not
if [ $(az storage container exists --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME | jq -r '.exists') = "false" ]; then
    echo "Storage container $CONTAINER_NAME does not exist. Creating..."
    az storage account create --resource-group $RESOURCE_GROUP --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob
    az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME
    echo "Storage container $CONTAINER_NAME created."
else
    echo "Storage container $CONTAINER_NAME already exists."
fi
