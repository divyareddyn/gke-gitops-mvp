variable "project_id" {
  description = "GKE Project ID for GitOps"
  type        = string
}

variable "region" {
  description = "GCP region for the network"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone for the cluster (zonal = cheaper)"
  type        = string
  default     = "us-central1-a"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "gke-gitops-mvp"
}

variable "machine_type" {
  description = "VM size for each node"
  type        = string
  default     = "e2-medium"
}

variable "node_count" {
  description = "Number of nodes"
  type        = number
  default     = 2
}
