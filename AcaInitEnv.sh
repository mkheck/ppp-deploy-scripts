#!/bin/bash
# Author  : Mark A. Heckler
# Notes   : Run with 'source AcaInitEnv.sh' from your shell/commandline environment
# History : 20240122 Official "version 1"
#         : 20240125 Polish, remove unused vars
#         : 20240126 Polish for push to GitHub

# REQUIREMENTS
## Azure CLI (az)

# Your Azure ID
export AZUREID='<your_azure_id>'
# export AZUREID='mkheck'   # Define an easily searchable prefix for resources

# Establish seed for random naming
export RANDOMIZER=$RANDOM
# AZ CLI
# export RANDOMIZER=n (where n equals the randomly assigned number above. Note this after running for future reference)
# Terraform
# export RANDOMIZER=n+1 (just uncomment & increment the above export's value by 1 if you want to run comparisons)

# Azure subscription to use
# export AZ_SUBSCRIPTION='<insert_your_azure_subscription_here>'    # If not set, will use default subscription
export AZ_RESOURCE_GROUP=$AZUREID'-'$RANDOMIZER'-rg'
export AZ_LOCATION='eastus'

# Container registry
export ACR_NAME='mkheckcontainerregistry'
export ACR_REGISTRY_SVR=$ACR_NAME'.azurecr.io'
# Registry can be defined in a different resource group; if not, use second line below instead
export ACR_RESOURCE_GROUP='mkheck-sb-rg'
# export ACR_RESOURCE_GROUP=$AZ_RESOURCE_GROUP

# Managed Identity used in Terraform creation/deployment of app
export ACR_MANAGED_IDENTITY=$AZUREID'-'$RANDOMIZER'-mgd-id'

# Service Principal name must be unique within your AD tenant
export SP_NAME='mkheckcontainerregistrysp'

# Obtain the full registry ID
export ACR_REGISTRY_ID=$(az acr show -n $ACR_NAME -g $ACR_RESOURCE_GROUP --query "id" --output tsv)

# App
export DOCKER_ID='<insert_your_Docker_ID_here>'
# export DOCKER_ID='hecklerm'
export IMAGE_NAME='ppp-deploy-pg'   # Set to appropriate image name
export IMAGE_TAG='0.0.1-SNAPSHOT'   # Set to appropriate image tag

# Container apps
export CONTAINERAPP_ENV=$AZUREID'-cae'  # Container apps environment
export CONTAINERAPP_NAME=$AZUREID'-'$IMAGE_NAME

# Terraform
export TF_VAR_AZ_LOCATION=$AZ_LOCATION
export TF_VAR_AZ_RESOURCE_GROUP=$AZ_RESOURCE_GROUP

export TF_VAR_AZ_CONTAINERAPP_ENV=$CONTAINERAPP_ENV
export TF_VAR_AZ_CONTAINERAPP_NAME=$CONTAINERAPP_NAME

export TF_VAR_ACR_NAME=$ACR_NAME
export TF_VAR_ACR_REGISTRY_SVR=$ACR_REGISTRY_SVR
export TF_VAR_ACR_RESOURCE_GROUP=$ACR_RESOURCE_GROUP
export TF_VAR_ACR_MANAGED_IDENTITY=$ACR_MANAGED_IDENTITY
export TF_VAR_DOCKER_ID=$DOCKER_ID
export TF_VAR_IMAGE_NAME=$IMAGE_NAME
export TF_VAR_IMAGE_TAG=$IMAGE_TAG
