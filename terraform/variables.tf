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
variable "git_repo_url" {
  description = "Git repo that Argo CD watches"
  type        = string
  default     = "https://github.com/divyareddyn/gke-gitops-mvp.git"
}

variable "argocd_chart_version" {
  description = "Pinned argo-cd Helm chart version"
  type        = string
  default     = "10.10.2"
}

variable "argocd_apps_chart_version" {
  description = "Pinned argocd-apps Helm chart version"
  type        = string
  default     = "2.0.6"
}
