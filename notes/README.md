# Monitoring

## Monitoring and Kubernetes

Back in the day, whenever you spun up a new server, if you wanted it monitored, you had to add it to the config of your monitoring system by hand. This is no longer true (there have been several ways to automate this for many, many years already).

Modern systems rely on Service Discovery to add services to monitoring. For example, you can configure Prometheus (a time-series based monitoring system) to automatically pick up any new services that are created in the cluster.

That way, you can pretty much see in real time whenever new applications are deployed or, if you define proper metrics, see if there are glaring differences between the current deployment and a new version of your application code.

## Logging and Kubernetes

Also logging: Kubernetes makes things on that front so easy when your deployments are properly labelled.

Instead of looking up which application servers you need to login to for looking at live logs (you also have a central log aggreator, right?), you'd just do:

```
kubectl logs -f -l app=wordpress,environment=prod
```

and you magically tail the logs of all your Pods that are labelled with `app: wordpress` and `environment: prod`

For proper aggregation, you usually send your logs to an external sink (like a Syslog server or Logstash). This is also something that with Kubernetes is relatively straightforward.

You no longer configure logging separately in each of your application instances, instead you'd log everything to `stdout` and `stderr` and have some service in the cluster, like Fluentd, pick it up. Fluentd then sends those logs in a structured format to an external sink, so you can quickly filter by namespaces and services.

