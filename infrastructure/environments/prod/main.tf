terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
  backend "gcs" {
    bucket  = "your-terraform-state-bucket"
    prefix  = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. Network Layer (VPC)
resource "google_compute_network" "vpc" {
  name                    = "llm-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "llm-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# 2. Vertex AI Endpoint (The LLM Host)
resource "google_vertex_ai_endpoint" "endpoint" {
  display_name = "llm-production-endpoint"
  location     = var.region
  project      = var.project_id
}

# 3. Cloud Run Service ( The Middleware API)
resource "google_cloud_run_service" "api_gateway" {
  name     = "llm-api-gateway"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/llm-api:latest"
        env {
          name  = "VERTEX_ENDPOINT_ID"
          value = google_vertex_ai_endpoint.endpoint.id
        }
        resources {
          limits = {
            memory = "1Gi"
            cpu    = "1000m"
          }
        }
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

# 4. IAM - Allow public access (or restrict as needed)
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.api_gateway.location
  project     = google_cloud_run_service.api_gateway.project
  service     = google_cloud_run_service.api_gateway.name
  policy_data = data.google_iam_policy.noauth.policy_data
}