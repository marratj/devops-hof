## Kubernetes Load Balancers 

#### Beware when draining nodes!


----

## Marcel Juhnke

#### SRE @ karrieretutor.de

---

### Easy migrations & failover

# Yeah!

----

#### Scheduler 
controls Pod placement

#### Node drain 
* moves Pods from the drained nodes to healthy ones
* good for planned maintanence work (replacing/upgrading nodes)

---

### What if the migration goes wrong?

----

#### before

<img src="images/nodedrain-before.svg" height="500px" />

----
#### added second node pool

<img src="images/nodedrain-secondpool.svg" height="500px" />

----
#### `kubectl drain`

<img src="images/nodedrain-after_blown.svg" height="500px" /> 
<div class="what">???</div>

----
No more traffic reached the ingress-nginx Pods

---
After `kubectl drain` cordoned the old nodes, the Kubernetes Service Controller

* added the new nodes to the GCP Load Balancer backend config
* removed the old node from the GCP Load Balancer backend config

Nodes that are not `Ready` get removed from the Load Balancer config

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



----
#### ingress-nginx still running on old nodes

Nodes didn't get drained due to Pod disruption budgets.

<p class="footnote">
Kubernetes will respect the PodDisruptionBudget and ensure that only one pod is unavailable at any given time. Any drains that would cause the number of ready replicas to fall below the specified budget are blocked:
<br />
<br />
https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/#draining-multiple-nodes-in-parallel
</p>

----

However, this shouldn't be a problem.

----
# But still

No more traffic reached the ingress-nginx Pods

---
### `kube-proxy`

This is what normally happens:

<img src="images/nodedrain-kube-proxy.svg" height="500px" />

Note: kube-proxy transparently forwards service traffic to the correct node(s) where the Pods are running.
----
However, it didn't in our case.

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

----
And after cordoning the nodes to this

<img src="images/nodedrain-after_blown_healthz.svg" height="500px" /> 

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