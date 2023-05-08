# Pods

## What is a pod?
Container are designed to ideally run and handle only a single process (unless the process generate child processes),
isolating them from the rest of the cluster. So, if there are multiple unrelated process, one can think that containers
cannot communicate each other from two different nodes. But this is not true, because there is an high-level structure,
called **pod**, that permits to encapsulate containers, binding them as a single unit.  
So, a pod is a collection of one or more containers that runs on the same worker node (co-location). They are associate to 
the same Linux namespace and can be referred as a separate machine (logically speaking), so with a specific network 
address, processes, resources, and so on. The pod can be either a single application with a single process or 
an union of multiple applications, each one with multiple processes, that run on its own container but all runs on the
same node. A hierarchical structure of the structure of infrastucture is the following:  

![hierarchical view](../static/01-pod-hierarchy-view.png)

## Pod networking
All the containers of a pod run under the same network and Linux namespace, so they share the same hostname and network
interface and can communicate each other through IPC (inter-process communication). But they cannot use a common filesystem
directly and by default. This because each container filesystem comes from container image and this one is fully isolated
and cannot be reached by another container. For accomplish a common storage space, it can be used the concept of **volume**.  
Due to the fact that container in a pod runs on the same network, they share the same IP address and port set and can 
communicate using a same network interface through localhost. So, the ports used by different processes must not overlap 
each other or this can cause a ports conflict. This is applied only for containers of the same pod: for containers of 
different pods, this is not a problem because each pod has a separate port space.  
All pods in a cluster are contained in a single shared network, so they can communicate each other without routing to
external context. The pods can communicate each other using directly the other pod's IP, without the needing of a NAT
gateway that translate a logical address to the real one. So, the communication between pods is always simple, even if 
the pods are located in different nodes.

![flat network](../static/01-pod-flatnetwork.png)

A great advantage of the pod isolation is the possibility to the separation of concerns. The isolation permits to separate
the different applications into separated pods, on which the Kubernetes Control Pane can execute a different handling. For
example, a more memory-intensive application (i.e. a backend application) can be separated in a totally different pod 
from a less eager one (i.e. a frontend application) in order to reduce speed-down issues.  
In this case, the **scaling** operation can be executed more easily, permitting a different approach of replication for
the two applications on different moments and cases.

## Pod descriptor
As is the case of other Kubernetes resource, pods can be created using JSON or YAML manifest document that will be 
passed to the Kubernetes Rest API endpoint.  
The pod definition consists of few main parts:
 - Metadata: including name, namespace, labels and other information about the pod
 - Specifications: including description of pod contents such as container, volume and so on
 - Status: including the current information about the running pod and each container located into it.

A simple structure of a descriptor can be the following:
```yaml
apiVersion: v1               (K8s API version)
kind: Pod                    (Descriptor for Pod instance)
metadata:
  name: pod-example-label    (Metadata)
spec:
  containers:
  - image: image/name        (Name of the image)
    name: container-name     (Name of the container)
    ports:
    - containerPort: 8080    (Port where the container will be exposed)
      protocol: TCP
```

### TO-DO
 - kubectl commands:
   - kubectl get pods
   - kubectl describe pod
 - Pod and labels
 - Pod annotation
 - Namespace management