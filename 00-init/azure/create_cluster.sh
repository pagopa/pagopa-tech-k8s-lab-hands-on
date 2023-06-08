## 
##  usage example:
##      sh create_cluster.sh westeurope pagopa-d-weu-dev-aks-lab-rg pagopa-lab-aks-cluster Standard_D2as_v5
##

subscription=DEV-pagoPA

location=$1
aks_resource_group=$2
aks_name=$3
vm_sku=$4

function show_usage ()
{
    echo
    echo "Usage: $0 \t<location> <aks_resource_group> <aks_name> <vm_sku>"
    echo
    exit 1
}

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
    show_usage
fi

echo "[INFO] Subscription: ${subscription}"
az account set -s "${subscription}"

echo "[INFO] location ${location}"
echo "[INFO] aks_resource_group ${aks_resource_group}"
az group create --location ${location} --resource-group ${aks_resource_group}

echo "[INFO] aks_name: ${aks_name}"
az aks create --node-count 2 \
              --generate-ssh-keys \
              --node-vm-size ${vm_sku} \
              --name ${aks_name} \
              --resource-group ${aks_resource_group}

# az aks get-credentials --name pagopa-lab-aks-cluster --resource-group pagopa-d-weu-dev-aks-lab-rg
az aks get-credentials --name ${aks_name} --resource-group ${aks_resource_group}

# kubectl config use-context pagopa-lab-aks-cluster
kubectl config use-context "${aks_name}"
kubectl get pods