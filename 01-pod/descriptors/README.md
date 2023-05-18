# Instructions

First of all, if it has already been created, connect to your cluster, e.g.:

`$ sh connect_cluster.sh --namespace namespace-name --rg pagopa-d-weu-dev-aks-lab-rg --name pagopa-lab-aks-cluster`  

Otherwise, create it, e.g.:

`$ sh create_cluster.sh westeurope pagopa-d-weu-dev-aks-lab-rg pagopa-lab-aks-cluster Standard_D2as_v5`  

Check pods in your namespace:

`$ kubectl get pods`

Create new pod using nginx-pod descriptor:

`$ kubectl apply -f nginx-pod.yaml`

Get pods list after apply:

`$ kubectl get pods`

Port-forwarding is required to connect to the pod deployed on the cluster from local; 
enable it and test connection:
```
$ kubectl port-forward nginx-pod ${port_forward}:80

$ curl -o /dev/null -s -w "%{http_code}\n" "http://localhost:${port_forward}"
```

more info on port-forwarding [here](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)