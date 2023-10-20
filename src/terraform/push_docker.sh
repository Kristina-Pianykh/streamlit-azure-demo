#!/usr/bin/env bash

export $(cat ../../env | xargs)
ACR_NAME="${PROJECT_NAME}acr"
IMAGE_NAME="${PROJECT_NAME}-image"

push_image() {
    docker image build -t $IMAGE_NAME ../../
    docker tag $IMAGE_NAME streamlittoyappacr.azurecr.io/${IMAGE_NAME}
    az acr login --name $ACR_NAME
    docker push streamlittoyappacr.azurecr.io/${IMAGE_NAME}
}

push_image
