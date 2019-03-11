---
title: Kubernetes Basics
revealOptions:
    transition: 'fade'

---

# Introduction to Kubernetes

----

## Marcel D. Juhnke

#### SRE @ karrieretutor.de

---
## What is Kubernetes?

The website says

> Kubernetes (k8s) is an open-source system for automating deployment, scaling, and management of containerized applications.

----

## Why is that important?

You usually don't manually want to

* pick the server your app is running on
* make sure all replicas are running the same version
* configure a Load Balancer to add new endpoints
* restart your app in case of errors

... the list goes on

---

## Core Task -> Scheduling Pods (Containers)

----

* Master node(s)
* Worker nodes

----

## Kubernetes masters

Those contain all the components required for managing a cluster

* API Server
* Scheduler
* Controllers

Together, those manage all the workloads in the cluster

----

## (Worker) Nodes

Here we have three main components

* container runtime (most often Docker)
* kubelet
* kube-proxy

---

## Basic objects

Minimal set of basic objects

* Nodes
* Pods
* Services

---

## Nodes

Run workloads (obviously)

<img class="center" src="images/nodes.svg" />

---

## Pods

* Core object
* Everything revolves around Pods
* Smallest deployable object

----

## Pods

* Single application instance per Pod
* Contains one or more containers
* Containers share volumes and network namespace
* For multiple instances -> create multiple identical Pods

----

<img class="center" src="images/pod.svg" />


----

<img class="center" src="images/pods.svg" />


----

## Scheduler

Decides where to place Pods based on their specs

* Resource requests/limits
* Affinitys

----
<img class="center" src="images/nodes-scheduler.svg" />

---
## Deployments

* Declarative updates/rollbacks for Pods
* Manages ReplicaSets -> identical Pods

----

<img class="center" src="images/deployment.svg" />


----

<img class="center" src="images/deployment_update1.svg" />

----

<img class="center" src="images/deployment_update2.svg" />

----

<img class="center" src="images/deployment_update3.svg" />

----

<img class="center" src="images/deployment_update4.svg" />

---



## Services

* Abstraction layer above Pods
* Discovery
* Load Balancing

----

* Pods can restart any time due to deployments and errors
* Scheduler can place them randomly
* Clients don't want to care where Pods are running

----

<img class="center" src="images/services.svg" />

----

<img class="center" src="images/services2.svg" />

----

## Service Networking

* Services implement a virtual IP 
* each Service is reachable on each node
* kube-proxy configures iptables NAT rules
* kube-proxy transparently forwards traffic between nodes

----

<img class="center" src="images/services-kube-proxy.svg" />

---

## Client access

----

Until here, everything was within the cluster.

How do we get external traffic inside?

----

## Node Port Services

<img class="center" src="images/nodeport-services.svg" height="500px" />

----

## kube-proxy

<img class="center" src="images/nodeport-kube-proxy.svg" height="500px" />

----

## Load Balancer

<img class="center" src="images/nodeport-loadbalancer.svg" height="500px" />

----

## Ingress

<img class="center" src="images/ingress-controller.svg" height="500px" />

----

<img class="center" src="images/ingress-reverse-proxy.svg" height="500px" />

---

## Thank you for your time!