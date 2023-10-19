#!/usr/bin/env bash

SUBSCRIPTION_ID=$(az account show --query id --output tsv)
RESOURCE_GROUP="rg-streamlit-test"
SERVICE_PRINCIPAL_NAME="TerraformPrinciple"
GROUP_ID=$(az group show --name $RESOURCE_GROUP --query id --output tsv)

az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --role Contributor --scope $GROUP_ID --sdk-auth
