POD_MAX_MEMORY=$(kubectl get clusterpolicy sandbox-namespace-limits -o yaml | yq '.spec.rules[1].generate.data.spec.limits[] | select(.type =="Pod") | .max.memory ' | tr -d '\n')
if [ "$POD_MAX_MEMORY" != "2Gi" ]; then
    echo "The Pod max memory should be set at least to 2Gi, instead was $POD_MAX_MEMORY"
    echo "Patching the cluster policy"
    kubectl get clusterpolicy sandbox-namespace-limits -o yaml \
        | yq eval '(.spec.rules[] | select(.name == "deploy-limit-ranges") .generate.data.spec.limits[] | select(.type == "Pod") .max.memory) = "2Gi"' - \
        | kubectl apply -f -
else
    echo "Pod max memory correctly set to 2Gi"
fi
