#!/bin/zsh

NAMESPACE=$1
GITOPS_SECRET_NAME=tap-gitops-ssh-auth

if [ -z "$NAMESPACE" ]; then
    echo "Namespace is required"
    echo "usage: ./prepare-env.sh <namespace>"
    exit 1
fi

kubectl create ns "$NAMESPACE"
kubectl label namespace "$NAMESPACE" apps.tanzu.vmware.com/tap-ns=""

kubectl get secret "$GITOPS_SECRET_NAME" -o yaml \
    | yq 'del(.metadata["namespace","resourceVersion","uid","creationTimestamp"])' \
    | kubectl apply -n "$NAMESPACE" -f -

kubectl annotate --overwrite ns "$NAMESPACE" param.nsp.tap/supply_chain_service_account.secrets='["registries-credentials", "tap-gitops-ssh-auth"]'
kubectl annotate --overwrite ns "$NAMESPACE" param.nsp.tap/delivery_service_account.secrets='["registries-credentials", "tap-gitops-ssh-auth"]'
