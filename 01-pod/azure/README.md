
# How to pull images from an Azure container registry to a Kubernetes cluster using a pull secret
To use an Azure container registry as a source of container images with any Kubernetes cluster, 
you must create a Kubernetes pull secret using the credentials of an Azure container registry. 
Then, use the secret to pull images from an Azure container registry in a pod deployment. 
Use Microsoft documentation to complete the task:
https://learn.microsoft.com/en-us/azure/container-registry/container-registry-auth-kubernetes#create-a-service-principal