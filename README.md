# streamlit-azure-demo

A toy infrastructure on Azure for hosting a publicly accessible streamlit Web application.

This repository leverages GitHub Actions for the automatically deployment of a containerized streamlit application on Azure. This includes:

* **Formatting Checks** to ensure code quality by running formatting checks
* **Docker Image Building**
* **Azure Container Registry (ACR)** for storing the Docker image
* **Azure Container Instance (ACI)** for deploying the application in a serverless container
* **Public Access** to ensure the app is accessible via a public IP address on port `8501`

![azure_streamlit_infra](azure_streamlit_infra.jpg)
