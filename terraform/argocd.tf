# ---------- Install Argo CD ----------
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = "argocd"
  create_namespace = true

  set = [
    { name = "dex.enabled", value = "false" },
    { name = "notifications.enabled", value = "false" },
  ]

  depends_on = [google_container_node_pool.main]
}

# ---------- Instruct Argo CD what to deploy ----------
resource "helm_release" "podinfo_app" {
  name       = "podinfo-app"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = var.argocd_apps_chart_version
  namespace  = "argocd"

  values = [yamlencode({
    applications = {
      podinfo = {
        namespace = "argocd"
        project   = "default"
        source = {
          repoURL        = var.git_repo_url
          targetRevision = "main"
          path           = "k8s"
        }
        destination = {
          server    = "https://kubernetes.default.svc"
          namespace = "podinfo"
        }
        syncPolicy = {
          automated   = { prune = true, selfHeal = true }
          syncOptions = ["CreateNamespace=true"]
        }
      }
    }
  })]

  depends_on = [helm_release.argocd]
}
