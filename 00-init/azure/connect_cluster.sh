##
##  usage example:
##      sh connect_cluster.sh --namespace namespace-name --rg pagopa-d-weu-dev-aks-lab-rg --name pagopa-lab-aks-cluster
##

# Getting arguments
while [ $# -gt 0 ]; do
    if [[ $1 == "--"* ]]; then
        v="${1/--/}"
        declare "$v"="$2"
        shift
    fi
    shift
done
echo "\n\n--------------------------"

# Check mandatory arguments
if [[ -z ${rg} ]]; then
  echo "No resource group set. It must be set with flag '--rg'"
  exit
fi
if [[ -z ${name} ]]; then
  echo "No cluster name set. It must be set with flag '--name'"
  exit
fi
if [[ -z ${portfwd} ]]; then
  portfwd=8080
fi

# Setting arguments
aks_resource_group=${rg}
aks_name=${name}
aks_namespace=${namespace}

# Connecting to AKS cluster and using that context
az aks get-credentials --name ${aks_name}  --resource-group ${aks_resource_group}
kubectl config use-context ${aks_name}

# Generating namespace if passed as argument
if [[ aks_namespace ]]; then
  kubectl create ns ${aks_namespace}
  kubectl config set-context --current --namespace=${aks_namespace}
fi