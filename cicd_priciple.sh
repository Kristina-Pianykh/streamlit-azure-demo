#!/usr/bin/env bash

export $(cat env | xargs)
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SERVICE_PRINCIPAL_NAME="TerraformPrinciple"
GROUP_ID=$(az group show --name $RESOURCE_GROUP --query id --output tsv)

az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --role Contributor --scope $GROUP_ID --sdk-auth
