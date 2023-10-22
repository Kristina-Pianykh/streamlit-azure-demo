# streamlit-azure-demo
## Description

A toy infrastructure on Azure for hosting a publicly accessible streamlit Web application. Once the infrastructure is deployed ([see the instructions below](#deployment-and-destrution)), the app is available at https://webapp-streamlittoyapp.azurewebsites.net/

![infra_web_app](infra_web_app.jpg)

## Deployment and Destrution

The app can be deployed in three ways:

1. via manual execution in the GitHub UI (`Actions` tab -> `deploy` -> `Run Wornflow`)
2. via Github Workflows (on push)
3. locally with the `terraform_deploy.sh` script

For the sake of cost optimization for this toy project, the whole insfrastructure can be taken down by:

1. manually triggering the `destroy` workflow in the GitHub UI
2. running the `terraform_destroy.sh` script
