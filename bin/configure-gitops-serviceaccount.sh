# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/namespace-provisioner-parameters.html#namespace-parameters
SERVICE_ACCOUNT_SECRET=$(kubectl get sa default -o yaml | yq '.secrets[] | select(.name == "tap-gitops-ssh-auth") | .name' | tr -d '\n')
if [ "$SERVICE_ACCOUNT_SECRET" != "tap-gitops-ssh-auth" ]; then
    echo "The gitops secret should be associated with the default service account"
    echo "Patching the service account via namespace provisioner annotations to include the tap-gitops-ssh-auth secret"
    kubectl annotate --overwrite ns apps param.nsp.tap/supply_chain_service_account.secrets='["registries-credentials", "tap-gitops-ssh-auth"]'
    kubectl annotate --overwrite ns apps param.nsp.tap/delivery_service_account.secrets='["registries-credentials", "tap-gitops-ssh-auth"]'
else
    echo "The gitops secret is associated with the default service account"
fi
