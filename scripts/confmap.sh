#!/bin/bash

set -euo pipefail

cNone='\033[00m'
cRed='\033[01;31m'
cGreen='\033[01;32m'

INIT=$1
NAMESPACE=$2
APPLICATION_NAME=$3

CONFIGMAP_NAME=${APPLICATION_NAME}-vault-data-hash

if [[ $INIT == true ]]; then
  echo -e "${cGreen}[!] Checking for presence of ConfigMap...${cNone}"

  if [[ ! $(kubectl get configmap -n $NAMESPACE $CONFIGMAP_NAME | grep $CONFIGMAP_NAME) ]]; then
    echo -e "${cRed}[x] ConfigMap ${CONFIGMAP_NAME} not found!${cNone}"
    echo -e "${cGreen}[!] Generating ConfigMap $CONFIGMAP_NAME...${cNone}"
    kubectl create configmap $CONFIGMAP_NAME --from-literal=vault-data-hash=$(cat /vault/secrets/app | md5sum | cut -d' ' -f1)

    if [[ $(kubectl get configmap -n $NAMESPACE $CONFIGMAP_NAME -o jsonpath='{.data.vault-data-hash}') == $(cat /vault/secrets/app | md5sum | cut -d' ' -f1) ]]; then
      echo -e "${cGreen}[!] ConfigMap $CONFIGMAP_NAME generated successfully!${cNone}"
    else
      echo -e "${cRed}[x] ConfigMap $CONFIGMAP_NAME generation failed.${cNone}"
      exit 1
    fi
  else
    echo -e "${cGreen}[!] ConfigMap exists. Skipping creation...${cNone}"
  fi
elif [[ $INIT == false ]]; then
  echo -e "${cGreen}[!] Checking for presence of ConfigMap...${cNone}"

  if [[ ! $(kubectl get configmap -n $NAMESPACE $CONFIGMAP_NAME | grep $CONFIGMAP_NAME) ]]; then
    echo -e "${cRed}[x] Error.${cNone}"
    exit 1
  else
    echo -e "${cGreen}[!] ConfigMap exists. Updating key vault-data-hash with current md5sum of /vault/secrets/app...${cNone}"
    kubectl create configmap $CONFIGMAP_NAME --from-literal=vault-data-hash=$(cat /vault/secrets/app | md5sum | cut -d' ' -f1) -o yaml --dry-run | kubectl apply -f -

    if [[ $(kubectl get configmap -n $NAMESPACE $CONFIGMAP_NAME -o jsonpath='{.data.vault-data-hash}') == $(cat /vault/secrets/app | md5sum | cut -d' ' -f1) ]]; then
      echo -e "${cGreen}[!] ConfigMap $CONFIGMAP_NAME updated successfully!${cNone}"
    else
      echo -e "${cRed}[x] ConfigMap $CONFIGMAP_NAME update failed.${cNone}"
      exit 1
    fi
  fi
fi
