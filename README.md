# vertex-ai-inference-platform
# Production-Ready LLM Inference Pipeline on GCP

![GCP](https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Vertex AI](https://img.shields.io/badge/Vertex_AI-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![CI/CD](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)

> **Enterprise-grade LLM operations platform** designed for high availability, security, and cost-effective inference at scale using Google Cloud Vertex AI and Cloud Run.

---

## 📖 Project Overview

This repository demonstrates a **production-grade MLOps architecture** for serving Large Language Models (LLMs). Unlike simple prototype deployments, this solution focuses on the "Day 2" operational challenges of running AI in the enterprise: **Reliability, Security, and Observability.**

The system exposes a secure API for internal applications, managing the lifecycle of requests from the edge (Load Balancer) to the inference engine (Vertex AI), with caching layers and strict IAM governance.

### 🎯 Key Objectives
* **Reliability:** Zero-downtime deployments (Blue/Green) and auto-scaling compute.
* **Security:** End-to-end encryption, VPC Service Controls, and PII redaction middleware.
* **Observability:** Full tracing of "Time to First Token" (TTFT) and cost tracking per tenant.
* **Automation:** Full Infrastructure as Code (IaC) and GitOps workflows.

---

## 🏗 Architecture

The architecture follows a **hub-and-spoke model** within a Virtual Private Cloud (VPC), utilizing managed services to reduce operational overhead.

```mermaid
graph TD
    User[Client App] -->|HTTPS| GLB[Cloud Load Balancing]
    GLB -->|Secure Access| APIG[API Gateway / Cloud Endpoints]
    
    subgraph "Orchestration Layer"
        APIG -->|Request| CR[Cloud Run Service]
        CR -->|Read/Write| Redis[(Cloud Memorystore)]
        CR -->|Secrets| SM[Secret Manager]
    end

    subgraph "Inference Layer (Vertex AI)"
        CR -->|Predict| V_End[Vertex AI Endpoint]
        V_End -->|Serve| V_Mod[Model Registry]
    end

    subgraph "Data & Ops"
        CR -->|Async Logs| PubSub[Cloud Pub/Sub]
        PubSub -->|Stream| BQ[(BigQuery)]
        CR -.->|Metrics| CloudMon[Cloud Monitoring]
    end
