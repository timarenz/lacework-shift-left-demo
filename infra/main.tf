provider "google" {
  project = var.gcp_project
}

provider "lacework" {}

data "google_client_config" "provider" {}

module "gcp" {
  source           = "git::https://github.com/timarenz/terraform-google-environment.git?ref=v0.2.4"
  environment_name = var.environment_name
  project          = var.gcp_project
  region           = var.gcp_region
}

module "k8s" {
  source           = "git::https://github.com/timarenz/terraform-google-kubernetes.git?ref=v0.5.2"
  project          = module.gcp.project_id
  environment_name = var.environment_name
  owner_name       = var.owner_name
  name             = "${var.environment_name}-k8s"
  network          = module.gcp.network
  subnet           = module.gcp.subnet_self_links[0]
  region           = var.gcp_region
  node_count       = 1
  machine_size     = "e2-small"
  oauth_scopes = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/cloud-platform"
  ]
}

provider "kubernetes" {
  host                   = module.k8s.endpoint
  cluster_ca_certificate = module.k8s.cluster_ca_certificate
  token                  = data.google_client_config.provider.access_token
}

data "lacework_agent_access_token" "k8s" {
  name = "${var.environment_name}-k8s"
}

module "agent" {
  source                = "lacework/agent/kubernetes"
  version               = "1.4.0"
  lacework_access_token = data.lacework_agent_access_token.k8s.token
  lacework_server_url   = var.lacework_server_url
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = var.app_name
    labels = {
      app = var.app_name
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          image = "ghcr.io/timarenz/lacework-shift-left-demo:v0.0.2"
          name  = var.app_name

          port {
            container_port = 5000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name = var.app_name
  }
  spec {
    selector = {
      app = kubernetes_deployment.app.metadata.0.labels.app
    }

    port {
      port        = 80
      target_port = 5000
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }
}

module "lacework_service_account" {
  source               = "lacework/service-account/gcp"
  version              = "1.0.0"
  project_id           = var.gcp_project
  service_account_name = "${var.environment_name}-sa"
}

module "lacework_config" {
  depends_on = [
    module.lacework_service_account
  ]
  source                       = "lacework/config/gcp"
  version                      = "1.1.1"
  project_id                   = var.gcp_project
  use_existing_service_account = true
  service_account_name         = module.lacework_service_account.name
  service_account_private_key  = module.lacework_service_account.private_key
  lacework_integration_name    = "${var.environment_name}-gcp-config"
}

module "lacework_audit_log" {
  depends_on = [
    module.lacework_config
  ]
  source                       = "lacework/audit-log/gcp"
  version                      = "2.2.0"
  use_existing_service_account = true
  service_account_name         = module.lacework_service_account.name
  service_account_private_key  = module.lacework_service_account.private_key
  required_apis                = {}
  lacework_integration_name    = "${var.environment_name}-gcp-audit-log"
  bucket_force_destroy         = true
  bucket_region                = "EUROPE-WEST4"
}
