##
##  usage example:
##      sh create_pod.sh --namespace namespace-name --rg pagopa-d-weu-dev-aks-lab-rg --name pagopa-lab-aks-cluster --portfwd 8080
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
port_forward=${portfwd}

# Connecting to AKS cluster and using that context
az aks get-credentials --name ${aks_name}  --resource-group ${aks_resource_group}
kubectl config use-context ${aks_name}

# Generating namespace if passed as argument
if [[ aks_namespace ]]; then
  kubectl create ns ${aks_namespace}
  kubectl config set-context --current --namespace=${aks_namespace}
fi

# Get pods list before apply
echo "Get pods list before apply..."
kubectl get pods
echo "\n\n--------------------------"

# Apply pod creation
echo "Apply pod creation..."
kubectl apply -f ../descriptors/nginx-pod.yaml
echo "\n\n--------------------------"

# Get pods list after apply
echo "Get pods list after apply..."
kubectl get pods
echo "\n\n--------------------------"

# Trying to connect to pod by port forward
echo "Opening a port with port forward from pod. You can try calling 'curl localhost:${port_forward}' in another terminal instance."
counter=0
max_retry=10
CMD_CHECK="503"
while (("$CMD_CHECK" != "200" && $counter < $max_retry))
do
    counter=$((counter + 1))
    sleep 1
    kubectl port-forward nginx-pod ${port_forward}:80
    CMD_CHECK=`curl -o /dev/null -s -w "%{http_code}\n" "http://localhost:${port_forward}"`
done
echo "--------------------------\n"

exit 0