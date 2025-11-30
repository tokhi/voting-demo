terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Start Minikube
resource "null_resource" "minikube_start" {
  provisioner "local-exec" {
    command = "minikube start --profile=voting-demo --driver=docker"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "minikube stop --profile=voting-demo || true"
  }
}

# Load local images into Minikube
resource "null_resource" "minikube_images" {
  depends_on = [null_resource.minikube_start]

  provisioner "local-exec" {
    command = <<EOT
      minikube image load voting-app-ruby-vote:latest --profile=voting-demo &&
      minikube image load voting-app-ruby-result:latest --profile=voting-demo &&
      minikube image load voting-app-ruby-worker:latest --profile=voting-demo
    EOT
  }
}

# Kubernetes provider
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "voting-demo"
}

# Helm provider
provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "voting-demo"
  }
}

# Deploy Helm chart
resource "helm_release" "voting-app-ruby" {
  depends_on = [
    null_resource.minikube_start,
    null_resource.minikube_images
  ]

  name             = "voting-app-ruby"
  chart            = "../helm"
  namespace        = "default"
  create_namespace = false

  set {
    name  = "vote.image.repository"
    value = "voting-app-ruby-vote"
  }
  set {
    name  = "vote.image.tag"
    value = "latest"
  }

  set {
    name  = "result.image.repository"
    value = "voting-app-ruby-result"
  }
  set {
    name  = "result.image.tag"
    value = "latest"
  }

  set {
    name  = "worker.image.repository"
    value = "voting-app-ruby-worker"
  }
  set {
    name  = "worker.image.tag"
    value = "latest"
  }
  set {
    name  = "vote.image.pullPolicy"
    value = "Never" 
  }
}
