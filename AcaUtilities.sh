#!/bin/bash
# Author  : Mark A. Heckler
# Notes   : Each section only meant to be run individually, when appropriate/useful
# History : 20240122 Official "version 1"
#         : 20240126 Polish for push to GitHub

## List resource groups for this account
az group list | jq -r '.[].name'
or
az group list --query "[].name" --output tsv

## Burn it to the ground
az group delete -g $AZ_RESOURCE_GROUP --subscription $AZ_SUBSCRIPTION -y

## Create/deploy script runner, timer, logger
time <script> | tee deployoutput.txt
