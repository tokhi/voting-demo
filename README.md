# Voting App - DevOps Quick Guide

This repository contains a simple Ruby voting application with three components: `vote`, `result`, and `worker`. The app uses **Redis** for caching votes and **Postgres** for storing results.

---

## Docker Compose Workflow

Bring up the full app locally with Docker Compose:

```bash
# Stop and remove containers, networks, and volumes
docker compose down -v

# Build and start all containers
docker compose up --build



# Minikube / Kubernetes Workflow

Use Minikube to run the app on Kubernetes:

## Reset Docker environment to local Minikube
eval $(minikube docker-env -u)

## Delete all pods if you want a clean start
kubectl delete pods --all

## Remove old Docker images if needed
docker rmi result-app

## Check services and endpoints
kubectl get svc
kubectl get endpoints

Running Services

Start the Minikube tunnel to expose LoadBalancer services:

minikube tunnel -p voting-demo


Access the services in your browser:

minikube service voting-app-ruby-vote --profile=voting-demo
minikube service voting-app-ruby-result --profile=voting-demo

Helm Workflow

Install / uninstall the app using Helm:

# Uninstall the app from Kubernetes
helm uninstall voting-app-ruby


#Runiing the dashboard for voting-demo profile
 minikube dashboard -p voting-demo


helm upgrade --install voting-app-ruby helm

kubectl get deploy 

# login to pod
 kubectl exec -it thepod -- bash
