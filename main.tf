terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
  
}

resource "digitalocean_kubernetes_cluster" "lab_k8s" {
  name   = var.k8s_name  
  region = var.region
  version = "1.23.9-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 3
  }
}

resource "digitalocean_kubernetes_node_pool" "node_premium" {
  cluster_id = digitalocean_kubernetes_cluster.lab_k8s.id
  name       = "premium"
  size       = "s-4vcpu-8gb"
  node_count = 1
  tags       = ["inicitiva-devops"]

  labels = {
    service  = "inicitiva-devops"
  }
}  

variable "do_token" {}
variable "k8s_name" {}
variable "region" {}

output "kube_endpoint" {
    value = "digitalocean_kubernetes_cluster.lab_k8s.endpoint" 
}

resource "local_file" "kube_config" {
    content  = "digitalocean_kubernetes_cluster.lab_k8s.kube_config.0.raw_config"
    filename = "kube_config.yaml"
}