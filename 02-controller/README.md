# Controllers

## Probes and checking
When a pod is scheduled on a node, the Kubelet subsystem on the same node will run the containers and keep them
running as long as the pod exists and it restart them if the processes crashes. But, if the app stops without the crash 
of the process (for example if there is a OutOfMemory error), the JVM process can run indefinitely without being destroyed.
In order to avoid this problematic, Kubernetes permits to check if a container is still alive and for doing this it uses
the *liveness probes*. These probes are used to periodically querying the app and, if their execution fails or the 
container will be restarted.  
Kubernetes can define a probes using one of those mechanisms:
 - **HTTP GET**: in this case, the probe performs an HTTP GET request on the container address. If the probe receives a 
response and the HTTP response  code does not represent an error state, its execution can be defined as successful. 
If the probe receives an error HTTP response code, it tells the Kubelet to restarts the container. This probe will call
a custom URL, that must not require authentication, that will performs an internal status check for all the vital components.
 - **TCP Socket**: in this case, the probe perform a TCP connection to a specified port of the container and if the 
connection is defined successfully, the probe is successful. Otherwise the Kubelet restarts the container.
 - **Exec**: in this case, the probe execute a defined command inside the container and checks the command's exit code.
If the exit code si 0, the prove is successful, otherwise the Kubelet restarts the container. In a Java app, it is better
to not use *Exec* probes due to the fact that a new JVM will be generated for getting the liveness information.

A simple structure of a descriptor can be the following:
```yaml
apiVersion: v1                  (K8s API version)
kind: Pod                       (Descriptor for Pod instance)
metadata:
  name: pod-example-label       (Metadata)
spec:
  containers:
  - image: image/name           (Name of the image)
    name: container-name        (Name of the container)
    livenessProbe:          
      httpGet:              
        path: /                 (HTTP Liveness Probe path)
        port: 8080              (HTTP Liveness Probe port)
      initialDelaySeconds: 15   
```

When the liveness probe is installed and found that the container is not *healty*, it will restart the resource. If the 
command `kubectl get` will be executed, the `RESTART` column is shown and can be valorized with a certain value indicating
the number of times the container was restarted.  
The liveness probe can have additional options that can be explicitely set, such as *delay*, *timeout*, *period* and so on.
In this case, the initial delay is set in order to not execute immediately the probe starts. If the number of failures
exceeds the defined threshold, the container is restarted again.
For execute a restart operation, the Kubelet will first send a `SIGTERM` signal, with exit code 143, to gracefully terminate
the application. If the application will not respond correctly, it will be sent a `SIGKILL` signal, defined with exit code
137, that force the process kill.  

## What is a controller?
As described, the job of containers restarting is made entirely by the node on which the pod is located and the Kubernetes
Control Plane cannot have any part in this process. But if the node itself crashes, it must be a Control Plane job to
create the needed replacements. To make sure that the app is restarted on another node, the pod must be managed by other
mechanisms.  
One of this mechanism is called **ReplicationController**. This is a Kubernetes Resource that create and manage multiple 
replicas of a pod *type* and ensure that all those replicas are always alive: if one or more pods are destroyed for any reason,
the ReplicationController notices the missing pods and create a replacements for them. This provides:
 - that one or more pods of certain *type* is always running on the cluster
 - that when a node fails, the cluster is flexible and will not lost pods 
 - that the horizontal scaling is easier than if applied by hand

#### !! TODO merge image [Figure 4.1. When a node fails, only pods backed by a ReplicationController are recreated] 
####    with image [Figure 4.4. If a pod disappears, the ReplicationController sees too few pods and creates a new replacement pod] !!

As described by the image, when the node goes down and two pods are destroyed, the ReplicationController will recreate the 
*Pod1* pod because it is the one that must be handled by this resource. The *Pod2* pod will not be recreated and no one
notice this departure.  
So, a ReplicationController constantly monitors the list of running pods and make sure that the number is always the same.
For doing so, it execute a so-called **reconciliation loop** that provide to handle the replicas.  

#### !! TODO image [Figure 4.2. A ReplicationController’s reconciliation loop] !!

A Replication controller is composed of three different parts:
 - **label selector**: define the pod *type* under the ReplicationController scope
 - **pod template**: defines the blueprint of the pods during replica re-creation 
 - **replica counter**: defines the number of replicas that must run in the cluster

#### !! TODO image [Figure 4.3. The three key parts of a ReplicationController] !!

A simple structure of a descriptor can be the following:
```yaml
apiVersion: v1
kind: ReplicationController        (Descriptor for ReplicationController instance)
metadata:
  name: rc-name                    (Metadata)
spec:
  replicas: 3                      (Number of replicas for the pod type)
  selector:                        
    label: value                   (Label selector, a.k.a pod type)
  template:                        (Pod template information)
    metadata:
      labels:                      
        applabel: apptype                 
    spec:                          
      containers:                  
      - name: container-name                
        image: image/name         
        ports:                     
        - containerPort: 8080      
```

To create the ReplicationController using the descriptor, execute the command:

`$ kubectl create -f RC-NAME.yaml`

For simply show the information related to the controller, execute the command:

`$ kubectl get rc`

Finally, to delete a ReplicationController (and eventually cascading the deletion on child pods) simply execute the command:

`$ kubectl delete rc RC-NAME --cascade=true`

#### !! TODO image [Figure 4.7. Deleting a replication controller with --cascade=false leaves pods unmanaged] !!


## Label selector and scope
Changing the value of the label selector or the pod template will not have immediate effect on existing pods: the first
change will fall out the existing pods from the scope of the ReplicationController, the second will change the structure
of the pods only if they are re-created after the template changing, so the structure modification is not a retroactive
operation.  
Pods created from ReplicationController are not static bound to the same. In any moment the binding link between pod and
ReplicationController, defined by the label selector, can be changed and this can separate the pod from its main context.
By doing so, the pod continue to exists but is no more handled by the controller. For this reason, the "ownership" of a 
pod for a ReplicationController can be transferred to another one, triggering for the old owner the scaling up process.
For adding the label to a pod, simply execute the command (appending `--overwrite` ath the end of the command in update mode):  

`$ kubectl label pod POD-NAME LABELNAME=LABELVALUE`

Removing a pod from its current scope can be useful when specific actions must be executed on a certain pod. For example,
it can be used in a debug session, when a pod starts behaving badly.

#### !! TODO image [Figure 4.5. Removing a pod from the scope of a ReplicationController by changing its labels] !!

At the same mode, a ReplicationController's template can be modified on-the-run. As defined before, the only pods affected
will be the one constructed after the template change and the ones defined before will remain unmodified until their destruction.
So, to modify the old pods, simply destroy them.

#### !! TODO image [Figure 4.6. Changing a ReplicationController’s pod template only affects pods created afterward and has no effect on existing pods.] !!

For executing an update on the template, execute the command:

`$ kubectl edit rc CONTROLLER-NAME`

At the same mode, it is very easy to execute an horizontal scaling (up and down): simply execute the command:

`$ kubectl scale rc CONTROLLER-NAME --replicas=REPLICA-NUMBER`

After the edit, the ReplicationController will provide to create (or destroy) the pods until their number will be equals
to the same defined in the command. The scaling instruction for Kubernetes is a declarative approach and not an imperative 
one: the pods in the cluster will be generated defining the final state (the number of pods) instead of defining the 
mode for the creation.

## What is a ReplicaSet?
A **ReplicaSet** is an enhancement of ReplicationController that will be generated by a **Deployment** resource. The use
of ReplicaSet is recommended instead of ReplicationController because it can provide more expressive pod selectors. 
In fact, the ReplicaSet's selectors can handle an *expression* on multiple labels: for example, it can handle pods that
simultaneously have certain label and doesn't have another label.  
A simple structure of a descriptor can be the following:
```yaml
apiVersion: apps/v1beta2            (newer API version)
kind: ReplicaSet                    (Descriptor for ReplicaSet instance)
metadata:
  name: rs-name
spec:
  replicas: 3
  selector:
    matchLabels:                    
      label: value                  (selector on match condition)
  template:                         
    metadata:                       
      labels:
        applabel: apptype
    spec:                           
      containers:
        - name: container-name
          image: image/name
```

The substantial difference with ReplicationController is on the `selector` label: the one defined in ReplicaSet must be
defined under the `selector` property, instead of simply listing them as key-value pair. This provide the generation of
more complex expression, using the `matchExpression` selector:

```yaml
 selector:
   matchExpressions:
     - key: labelkey                      
       operator: In                  
       values:                       
         - value1
         - value2 
```

The permitted operators can be:
 - **In**: the label value must match one of the values included in `values`
 - **NotIn**: the label value must not match any of the values included in `values`
 - **Exists**: the label value must be whatever value (the field `values` cannot be inserted)
 - **DoesNotExists**: the label value must not exists (the field `values` cannot be inserted)

To create the ReplicationController using the descriptor, execute the command:

`$ kubectl create -f RS-NAME.yaml`

For simply show the information related to the controller, execute the command:

`$ kubectl get rs`

Finally, to delete a ReplicaSet simply execute the command:

`$ kubectl delete rs RS-NAME`

## What is a DaemonSet?
There can be cases on which a pod must be installed and run on each and every node in the cluster. This can be the cases
when must be installed infrastructure-related application that can provide system-level operation (such as log collector
or resource monitoring). For this work, a **DaemonSet** can be useful: it is a Kubernetes resource whose created pods 
are like ReplicationController or ReplicaSet ones but with the difference that are strictly correlated to the node on which
will be installed. The main task of DaemonSet is not providing the same amount of pods in the cluster but providing one 
and only pod for each node in the cluster, handling their lifecycle and providing their continue availability. So, if the
node goes down, the DaemonSet will not provide the "migration" of the pod to another node. But, if a new node is deployed,
the DaemonSet provide immediately the deploy of the pod in the new instance.  
With such potentiality, the DaemonSet can provide the pods deploying also on a subset of nodes: for doing so, simply 
define a label on the needed node and add a **node selector** on the descriptor.  

#### !! TODO merge image [Figure 4.8. DaemonSets run only a single pod replica on each node, whereas ReplicaSets scatter them around the whole cluster randomly] 
####         with image [Figure 4.9. Using a DaemonSet with a node selector to deploy system pods only on certain nodes] !!

A simple structure of a descriptor can be the following:
```yaml
apiVersion: apps/v1beta2           
kind: DaemonSet                    (Descriptor for Daemon instance)
metadata:
  name: ds-name
spec:
  selector:
    matchLabels:
      app: ssd-monitor
  template:
    metadata:
      labels:
        label: value
    spec:
      nodeSelector:                (node selector on match condition)
        nodeSelKey: value                  
      containers:
      - name: container-name
        image: image/name
```

To create the ReplicationController using the descriptor, execute the command:

`$ kubectl create -f DS-NAME.yaml`

For simply show the information related to the controller, execute the command:

`$ kubectl get ds`

For adding a label to a node, execute the command:

`$ kubectl label node NODENAME LABELNAME=LABELVALUE`

## What is a Job?
The previously illustrated sets generate pods that runs continuously. In the cases where a pod must run on one-shot 
execution or on scheduled time, there can be used **Jobs** and **CronJob**.  
The **Job** is a resource that permits to run a pod for a single process execution and permitting to not restarting it 
after the job termination. In the case of a node failure, the pods on that node managed by a Job will be rescheduled to 
other nodes in the same way the ReplicaSet pods are defined. In the event of process failure, the Job can either
restart or not, sa configured in the descriptor.  This resource is useful when ad-hoc tasks must be executed on the pod, 
such as data migration or other similar tasks.

#### !! TODO image [Figure 4.10. Pods managed by Jobs are rescheduled until they finish successfully] !!

A simple structure of a descriptor can be the following:
```yaml
apiVersion: batch/v1                  
kind: Job                             (Descriptor for Job instance)
metadata:
  name: batch-job
spec:                                 
  template:
    metadata:
      labels:                         
        labelkey: labelvalue                
    spec:
      restartPolicy: OnFailure        (policy for define the job restart)
      completions: COMPLETION-NUMBER
      parallelism: PARALLEL-EXEC
      containers:
      - name: container-name
        image: image/name
```

The value of the `restartPolicy` can be either `OnFailure` and `Never`. The Jobs can be configured to create more than 
one instance in the node and run them in parallel or in sequence. For doing this, it possible to set the properties
`completions` and `parallelism` properties.
For simply show the information related to the defined jobs, execute the command:

`$ kubectl get jobs`

Many jobs need to be run at specific time in the future or repeated in specific interval of time. In Unix-like system
this can be executed by cron jobs and in Kubernetes this can be performed with **CronJob** resources, using the same standard 
cron job format for generating (and then destroying) the needed pods.  
A simple structure of a descriptor can be the following:
```yaml
apiVersion: batch/v1beta1                  
kind: CronJob                              (Descriptor for Job instance)
metadata:
  name: batch-job-scheduled
spec:
  schedule: "0,15,30,45 * * * *"           (cron for job scheduling)
  startingDeadlineSeconds: MAX-DELAY      
  jobTemplate:
    spec:
      template:                            
        metadata:                          
          labels:                          
            labelkey: labelvalue        
        spec:                              
          restartPolicy: OnFailure         
          containers:                      
          - name: container-name                     
            image: image/name
```

Using the property `startingDeadlineSeconds` it is possible to set a maximum waiting time before the scheduled start time
and the real starting time, avoid the job to wait indefinitely the scheduled pod to start. If the job will not run
it will be set as *Failed*.
