---
title: Beware when draining nodes!
revealOptions:
    transition: 'fade'

---

## Migrate those ingress controllers first

#### Beware when draining nodes!

Note: Today I want to talk about a traffic outage we had in our infrastructure cluster a few weeks ago.
----

## Marcel D. Juhnke

#### SRE @ karrieretutor.de

Note: My name is Marcel Juhnke and I'm currently working as SRE @karrieretutor.de, where I am, together with a colleague, responsible for our cloud infrastructure. karriere tutor is a startup in the German e-learning market that specializes on learning partnerships with our national unemployment agency.
---

#### Kubernetes gives us easy migrations & failovers

We mostly have come to expect this as a simple fact

----

### But what if the migration goes wrong?

---

## Today's protagonists

#### Node drain 
* moves Pods from the drained nodes to healthy ones
* good for planned maintanence work (replacing/upgrading nodes)

#### Services/kube-proxy
* make sure that Pods are reachable no matter which node they run on.

---

#### before

<img src="images/nodedrain-before.svg" height="500px" />

Note: This is the initial situation from where we started. We had a node pool that we needed to recreate in GKE.
----
#### added second node pool

<img src="images/nodedrain-secondpool.svg" height="500px" />

Note: For this, we created a second node pool where we then wanted to simply migrate all workloads over to and kill off the old nodes.
----
#### `kubectl drain`

<img src="images/nodedrain-after_blown.svg" height="500px" /> 
<div class="what">???</div>

Note: So, blindly trusting our positive experiences from the past, we did a kubectl drain on ALL of the old nodes at once. We didn't really expect what we ended up with.
----
ingress-nginx Pods were still running on the old nodes

no traffic was redirected to them anymore

-> This shouldn't happen, right?

---

So let's see how the story unfolded

----

After `kubectl drain` cordoned the old nodes, they went to a `NotReady` state.

The Kubernetes Service Controller in turn

* added the new nodes to the GCP Load Balancer backend config
* removed the old node from the GCP Load Balancer backend config

Nodes that are not `Ready` get removed from the Load Balancer config

Note: so when you tell a node to be drained, it automatically get's cordoned, too. That means, it won't accept any new Pods to be scheduled on it and moves to a NotReady state. When a node is not ready, the Kubernetes Service Controller
----

```go
func getNodeConditionPredicate() corelisters.NodeConditionPredicate {
	return func(node *v1.Node) bool {
		// We add the master to the node list, but its unschedulable.  So we use this to filter
		// the master.
		if node.Spec.Unschedulable {
			return false
        }

        ...

        for _, cond := range node.Status.Conditions {
			// We consider the node for load balancing only when its NodeReady condition status
			// is ConditionTrue
			if cond.Type == v1.NodeReady && cond.Status != v1.ConditionTrue {
				klog.V(4).Infof("Ignoring node %v with %v condition status %v", node.Name, cond.Type, cond.Status)
				return false
			}
		}
        return true
    }
}
```
<p class="footnote">
https://github.com/kubernetes/kubernetes/blob/00eab3c40bcda9ee73eac060242d36602e627fec/pkg/controller/service/service_controller.go#L592https://github.com/kubernetes/kubernetes/blob/00eab3c40bcda9ee73eac060242d36602e627fec/pkg/controller/service/service_controller.go#L588
</p>


Note: This shows the place in the service controller's source code where it decides which nodes should be part of a cloud LB's backend config.
----
#### ingress-nginx still running on old nodes

Nodes didn't get drained due to Pod disruption budgets.

<p class="footnote">
Kubernetes will respect the PodDisruptionBudget and ensure that only one pod is unavailable at any given time. Any drains that would cause the number of ready replicas to fall below the specified budget are blocked:
<br />
<br />
https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/#draining-multiple-nodes-in-parallel
</p>

Note: The next situation that we faced were that the ingress-nginx Pods didn't get moved off the old nodes. We later found that this was due to Pod disruption budgets that were configured on a Deployment. We didn't configure this ourselves, as we didn't care about at that time; it was simply a default value in a Helm chart we used.
----

In that case, we'd normally expect this:

<img src="images/nodedrain-kube-proxy.svg" height="500px" />

Note: kube-proxy transparently forwards service traffic to the correct node(s) where the Pods are running.

----
## However, this was not the case


No more traffic reached the ingress-nginx Pods


---
# But why not?

----
Service definition:

```yaml
kind: Service
apiVersion: v1
metadata:
  name: ingress-nginx
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
spec:
  externalTrafficPolicy: Local
  type: LoadBalancer
```

Note: Let's have a look at the Service definition that comes with the deployment manifests of ingress-nginx. We notice the externalTrafficPolicy in there
----
externalTrafficPolicy

```yaml
spec:
  externalTrafficPolicy: Local
```
> <p class="footnote">Packets sent to Services with Type=LoadBalancer are source NAT’d by default, because all schedulable Kubernetes nodes in the Ready state are eligible for loadbalanced traffic. So if packets arrive at a node without an endpoint, the system proxies it to a node with an endpoint, replacing the source IP on the packet with the IP of the node.</p><p class="footnote">Setting service.spec.externalTrafficPolicy field to Local forces nodes without Service endpoints to remove themselves from the list of nodes eligible for loadbalanced traffic by deliberately failing health checks.</p>

<p class="footnote">https://kubernetes.io/docs/tutorials/services/source-ip/#source-ip-for-services-with-type-loadbalancer</p>

<p class="footnote">https://github.com/kubernetes/kubernetes/blob/139a13d312b1b11de7f3af63d9503365ff3a1e6a/pkg/proxy/healthcheck/healthcheck.go#L212</p>

<p class="footnote">https://github.com/kubernetes/kubernetes/blob/1c557b9ce866d67ec6088f37058e8594b89606ee/pkg/cloudprovider/providers/gce/gce_loadbalancer_external.go#L209</p>

Note: this feature is especially helpful in ingress-nginx's case, because without it, log entries would only show other nodes' IP addresses as source, instead of the real client IP.
----
Which leads to this situation

<img src="images/nodedrain-secondpool_healthz.svg" height="500px" /> 

Note: which leads to this situation after we added the second node pool

----
And after cordoning the nodes to this

<img src="images/nodedrain-after_blown_healthz.svg" height="500px" /> 

Note: And to this after the old nodes were set to NotReady after being cordoned
---

### Obvious solution

The drain operation was stalled due to misconfigured disruption budgets on our side (we didn't need them, they were kept from the Helm chart's default).

----
Delete ingress-nginx Pods on the cordoned nodes.

<img src="images/nodedrain-delete_pods.svg" height="500px" /> 

----
They get automatically recreated on the `Ready` nodes:

<img src="images/nodedrain-recreate_pods.svg" height="500px" /> 

---
# Bottom Line

----
* Check your service definitions twice (or thrice!)
* Don't drain all nodes at once 
  * -> we would have catched the error in time
* Observe the behavior of your system

---

## Thank you for your time!

Note: I'm happy to answer any questions.