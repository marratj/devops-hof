# Monitoring

## Logging and Kubernetes

Kubernetes makes things on that front so easy when your deployments are properly labelled.

Instead of looking up which application servers you need to login to for looking at live logs (you also have a central log aggreator, right?), you'd just do:

```
kubectl logs -f -l app=wordpress,environment=prod
```

and you magically tail the logs of all your Pods that are labelled with `app: wordpress` and `environment: prod`

For proper aggregation, you usually send your logs to an external sink (like a Syslog server or Logstash). This is also something that with Kubernetes is relatively straightforward.

You no longer configure logging separately in each of your application instances, instead you'd log everything to `stdout` and `stderr` and have some service in the cluster, like Fluentd, pick it up. Fluentd then sends those logs in a structured format to an external sink, so you can quickly filter by namespaces and services.