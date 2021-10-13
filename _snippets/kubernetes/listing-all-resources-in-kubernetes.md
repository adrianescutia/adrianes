---
title: Listing All Resources in Kubernetes
description: Two quick and easy ways of listing all the resources deployed in Kubernetes
tags:
  - Kubernetes
---

# Listing All Resources in Kubernetes

Two quick and easy options of listing all the resources deployed in Kubernetes.

Setting a **default namespace** (optional):  
`kubectl config set-context --current --namespace=my-namespace`

## Option 1

```sh
# Listing all the standard (pod, service, etc.) k8s resources in specific namespace
kubectl get all -n my-namespace
# Listing all the standard k8s resources in current context's default namespace
kubectl get all
```

## Option 2:

Or you can use function below. Advantage is that this function will list default 
resources and [Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) (CRDs) as well:

```sh
function kubectlgetall {
  for i in $(kubectl api-resources --verbs=list --namespaced -o name | grep -v "events.events.k8s.io" | grep -v "events" | sort | uniq); do
    echo "Resource:" $i
    
    if [ -z "$1" ]
    then
        kubectl get --ignore-not-found ${i}
    else
        kubectl -n ${1} get --ignore-not-found ${i}
    fi
  done
}
```

**Usage:** `kubectlgetall <namespace>`  

> namespace is optional

Example: get all resources from the `kafka` namespace:

`kubectlgetall kafka`

get all resources from default namespace:

`kubectlgetall`

---

References:

* Listing all resources in a namespace in [Stackoverflow](https://stackoverflow.com/a/55796558/5078874)
* How to list all resources in a kubernetes namespace - [Study Tonight](https://www.studytonight.com/post/how-to-list-all-resources-in-a-kubernetes-namespace)