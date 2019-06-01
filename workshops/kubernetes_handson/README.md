# DevOps Meetup Hof - Kubernetes Hands On Workshop

## Agenda

- Zugriff auf Kubernetes Cluster (die eigentliche From-Scratch-Installation würde leider den Zeitrahmen weit sprengen)
- Verwalten von Deployments/Pods/Containern
- Verwalten von Volumes
- Upgrades/Rollbacks von Deployments
- Zugriff auf Deployments/Pods über Services und Ingresses im Zusammenspiel mit Labels

## Vorbereitung

- DNS-Eintrag fuer Ingress
- ingress-nginx configmap
  - http->https redirect deaktivieren
```yaml
data:
  ssl-redirect: "false"
```

## Zugriff auf Kubernetes Cluster 

Cluster und Service Accounts sind vorgeneriert.

- kubectl herunterladen

https://kubernetes.io/docs/tasks/tools/install-kubectl/

- kubeconfig herunterladen und als ~/.kube/config oder alternativ:

```bash
export KUBECONFIG=/path/to/kubeconfig
```

## Verwalten von Pods/Containern

- Einfaches nginx Deployment per kubectl

```bash
# Einmal
kubectl create deployment nginx --image=nginx:1.15.0

kubectl get deployments

kubectl describe deployment nginx

kubectl get pods

# Dann mit YAML Output
kubectl create deployment nginx --image=nginx:1.15.0 --dry-run -o yaml > nginx_deployment.yaml

cat nginx_deployment.yaml

kubectl apply -f nginx_deployment.yaml
```

## Volumes

- ConfigMaps
- Secrets
- Persistent Volumes

```bash
# Erstellen einer ConfigMap

# Config File erstellen
echo "key=value" > configfile

kubectl create configmap nginx --from-file=configfile
```

```bash
kubectl create deployment nginx --image=nginx:1.15.0 --dry-run -o yaml > voltemplate.yaml

# Editieren des Templates
# Hinzufuegen des Volumes in Pod Template
# volumeMounts in Container konfigurieren
# ein paar unterschiedliche Volume-Typen zeigen

kubectl apply -f voltemplate.yaml
``` 

```bash
# erstellen eines PVCs

kubectl apply -f pvc.yaml
```

## Upgrades/Rollbacks

```bash
# Austauschen eines Images

# in Tab 1
watch kubectl get pods

# in Tab 2
kubectl set image deployment/nginx nginx=nginx:1.15.2

# Alternativ auch 
kubectl edit deployment/nginx
```

## Services

- ClusterIP
- LoadBalancer

Label Selectors!

```bash
kubectl create service loadbalancer nginx --tcp=80 --dry-run -o yaml > service.yaml

kubectl apply -f service.yaml

kubectl edit service nginx
```


## Ingress

```bash
kubectl apply -f ingress.yaml

kubectl edit ingress nginx
```