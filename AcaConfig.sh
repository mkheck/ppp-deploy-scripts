#!/bin/bash
# Author  : Mark A. Heckler
# Notes   : Run with 'source AcaConfig.sh' from your shell/commandline environment AFTER AcaInitEnv.sh
# History : 20240122 Official "version 1"
#         : 20240125 Minor tweaks, experimentation
#         : 20240126 Polish for push to GitHub

# REQUIREMENTS
## Azure CLI (az)

# Resource group config
echo '>> az group create -l $AZ_LOCATION -g $AZ_RESOURCE_GROUP --subscription $AZ_SUBSCRIPTION'
az group create -l $AZ_LOCATION -g $AZ_RESOURCE_GROUP --subscription $AZ_SUBSCRIPTION

# Container Apps environment config, deploy
echo '>> az containerapp env create -n $CONTAINERAPP_ENV -g $AZ_RESOURCE_GROUP -l $AZ_LOCATION'
az containerapp env create -n $CONTAINERAPP_ENV -g $AZ_RESOURCE_GROUP -l $AZ_LOCATION

# Create the service principal with rights scoped to the registry.
# Default permissions are for docker pull access. Modify the '--role'
# argument value as desired:
# acrpull:     pull only
# acrpush:     push and pull
# owner:       push, pull, and assign roles
export SP_PASSWORD=$(az ad sp create-for-rbac --name $SP_NAME --scopes $ACR_REGISTRY_ID --role acrpull --query "password" --output tsv)
export SP_USER_NAME=$(az ad sp list --display-name $SP_NAME --query "[].appId" --output tsv)

# Output the service principal's credentials; use these in your services and
# applications to authenticate to the container registry.
echo "Service principal ID: $SP_USER_NAME"
echo "Service principal password: $SP_PASSWORD"

# # Create managed identity with rights scoped to the registry.
# MH: Currently under evaluation/testing
# az identity create -n $ACR_MANAGED_IDENTITY -g $ACR_RESOURCE_GROUP
# az acr identity assign --identities $ACR_MANAGED_IDENTITY -n $ACR_NAME -g $ACR_RESOURCE_GROUP


# ****************************************************************************************************
# Need for both scripted approach and terraform
# NOTE: Must have Docker Desktop running locally and logged into ACR for this to work
docker tag hecklerm/$IMAGE_NAME:$IMAGE_TAG $ACR_REGISTRY_SVR/$DOCKER_ID/$IMAGE_NAME:$IMAGE_TAG

## Must be authenticated to ACR in order to successfully push an image
az acr login --name mkheckcontainerregistry

docker push $ACR_REGISTRY_SVR/$DOCKER_ID/$IMAGE_NAME:$IMAGE_TAG

az acr repository list -n $ACR_NAME --output table
# ****************************************************************************************************

# MH: Managed identity option currently under evaluation/testing; Service Principal tested and working
# Deploy containerized app to Azure Container Apps from container registry
# az containerapp create -n $CONTAINERAPP_NAME -g $AZ_RESOURCE_GROUP --environment $CONTAINERAPP_ENV \
#   --registry-server $ACR_REGISTRY_SVR --registry-username $SP_USER_NAME --registry-password $SP_PASSWORD \
  # --registry-server $ACR_REGISTRY_SVR --registry-identity $ACR_MANAGED_IDENTITY \
#   --image $ACR_REGISTRY_SVR/$DOCKER_ID/$IMAGE_NAME:$IMAGE_TAG \
#   --target-port 8080 \
#   --ingress 'external' \
#   --query properties.configuration.ingress.fqdn

# Deploy app (as .jar file) to Azure Container Apps; ACA automatically builds and deploys the container
az containerapp up -n $CONTAINERAPP_NAME -g $AZ_RESOURCE_GROUP --environment $CONTAINERAPP_ENV \
  --artifact ./target/$IMAGE_NAME-$IMAGE_TAG.jar \
  --target-port 8080 \
  --ingress 'external' \
  --query properties.configuration.ingress.fqdn
