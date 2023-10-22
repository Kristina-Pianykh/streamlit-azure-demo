#!/usr/bin/env bash

if [ "$#" -eq 0 ]; then
    echo "ERROR: $new_image_tag does not exist. Provide a image tag represented as timestamp in RFC 3339 format."
    exit 1
fi

new_image_tag=$1

# if [ ! -f "$new_image_tag" ]; then
#     echo "ERROR: $new_image_tag does not exist. Provide a image tag represented as timestamp in RFC 3339 format."
#     exit 1
# fi


export $(cat ../../env | xargs)
ACR_NAME="${PROJECT_NAME}acr"
IMAGE_NAME="${PROJECT_NAME}-image"

purge_older_images() {
    # List repositories in the ACR
    repository=$(az acr repository list -n $ACR_NAME --output tsv)
    # List tags for the repository
    tags=($(az acr repository show-tags -n $ACR_NAME --repository $repository --orderby time_asc --output tsv))
    # Delete older images
    for tag in "${tags[@]}"; do
        echo "Deleting image ${IMAGE_NAME}:${tag}"
        az acr repository delete -n $ACR_NAME --image "${IMAGE_NAME}:${tag}" --yes
    done
}

push_image() {
    docker image build -t $IMAGE_NAME ../../
    docker tag $IMAGE_NAME streamlittoyappacr.azurecr.io/${IMAGE_NAME}:${new_image_tag}
    az acr login --name $ACR_NAME
    docker push streamlittoyappacr.azurecr.io/${IMAGE_NAME}:${new_image_tag}
}

purge_older_images
push_image
