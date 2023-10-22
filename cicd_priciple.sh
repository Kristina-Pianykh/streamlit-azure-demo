#!/usr/bin/env bash

export $(cat env | xargs)
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SERVICE_PRINCIPAL_NAME="CICDPrinciple"
GROUP_ID=$(az group show --name $RESOURCE_GROUP --query id --output tsv)
export MSYS_NO_PATHCONV=1

echo "Creating service principle..."
az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --role Owner --scopes $GROUP_ID --sdk-auth

# create a custom role and assign it to the service principle
# az role definition create --role-definition custom_contributor_role.json
# az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --role Owner --scope $GROUP_ID --sdk-auth

# principle_id=$(az ad sp list --display-name $SERVICE_PRINCIPAL_NAME | jq -r '.[].id')

# az role assignment create --assignee $principle_id \
# --role "Owner" \
# --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP"

# get details on the role
# az role definition list --name "Custom Contributor"

# create a role from local json file
# az role definition create --role-definition custom_contributor_role.json --subscription $SUBSCRIPTION_ID

# unasign role from principle
# az role assignment delete --assignee $principle_id --role "Custom Contributor" --resource-group $RESOURCE_GROUP

# delete role
# role_name=$(az role definition list --name "Contributor" | jq -r '.[].name')
# az role assignment delete --assignee $principle_id --role $role_name --resource-group $RESOURCE_GROUP
