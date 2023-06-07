# Instructions

### Configuration

First of all, if it has already been created, connect to your cluster, e.g.:

`$ sh connect_cluster.sh --namespace namespace-name --rg pagopa-d-weu-dev-aks-lab-rg --name pagopa-lab-aks-cluster`  

Otherwise, create it, e.g.:

`$ sh create_cluster.sh westeurope pagopa-d-weu-dev-aks-lab-rg pagopa-lab-aks-cluster Standard_D2as_v5`  

## Exercise: Creating a Pod Declaratively

### Task 1

Check pods in your namespace:

`$ kubectl get pods`

Create new pod using nginx-pod descriptor:

`$ kubectl apply -f nginx-pod.yaml`

Get pods list after apply:

`$ kubectl get pods`

View complete definition of the Pod

`kubectl get pods nginx-pod -o yaml > mypod.yaml`

### Task 1 - extra

Port-forwarding is required to connect to the pod deployed on the cluster from local; 
enable it and test connection:
```
$ kubectl port-forward nginx-pod ${port_forward}:80

$ curl -o /dev/null -s -w "%{http_code}\n" "http://localhost:${port_forward}"
```

more info on port-forwarding [here](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)

### Task 2

Show all the labels in the pods

`$ kubectl get pods --show-labels`

List pods associated with a label named kind=reverse. You can use -l switch to apply filter based on labels.

`$ kubectl get pod -l kind=normal`

To show that it works as expected, run the command again, but change the value of label kind to `web`. Note that this time `kubectl` does not return any pods because there are no pods that match the label kind and `web` value.

`$ kubectl get pod -l kind=web`

## Exercise: Adding/Updating/Deleting Labels on a Pod

### Task 1

Assign a new label to a running Pod

`$ kubectl label pod nginx-pod health=fair`

Note that an additional label is now displayed with the Pod.

`$ kubectl get pods nginx-pod --show-labels`

### Task 2

Update an existing label that is assigned to a running Pod.

`$ kubectl label pod nginx-pod kind=web --overwrite`

Notice that kind has changed from reverse to web.

`$ kubectl get pods --show-labels`

### Task 3

Delete a label that is assigned to a running Pod.

`$ kubectl label pod nginx-pod health-`

Notice the minus (-) sign at the end of the command. You can also remove a label from all running pods by using the --all flag.

`$ kubectl label pod health- --all`

Notice that health is not part of the list of labels.

`$ kubectl get pods --show-labels`

### Task 4

Delete Pods based on their labels.

`$ kubectl delete pod -l target=dev`


### Cleanup

From destroy directory:

`$ sh destroy.sh <aks_resource_group> <aks_name>`

In the case of our example:

`$ sh destroy.sh pagopa-d-weu-dev-aks-lab-rg pagopa-lab-aks-cluster`