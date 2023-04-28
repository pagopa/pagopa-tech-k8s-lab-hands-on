## 
##  usage example:
##      sh destroy.sh pagopa-lab-aks-cluster pagopa-d-weu-dev-aks-lab-rg
##

subscription=DEV-pagoPA

aks_name=$1
aks_resource_group=$2

function show_usage ()
{
    echo
    echo "Usage: $0 \t<aks_resource_group> <aks_name>"
    echo
    exit 1
}

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    show_usage
fi

echo "[INFO] Subscription: ${subscription}"
az account set -s "${subscription}"

echo "[INFO] delete aks ${aks_name}"
az aks delete --name ${aks_name}  --resource-group ${aks_resource_group}
echo

echo "[INFO] delete resource group ${aks_resource_group}"
az group delete --name ${aks_resource_group}