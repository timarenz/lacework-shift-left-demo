terraform {
  required_providers {
    lacework = {
      source  = "lacework/lacework"
      version = "0.11.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "3.87.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.7.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}
