# ADR 001: Selection of Vertex AI over Self-Hosted GKE for Inference

# Status
Accepted

# Context
We need to serve a Llama 2 (70B) model. We have two primary options:
1. Self-Hosted: Managing GPU nodes on GKE (Google Kubernetes Engine).
2. Managed: Using Vertex AI Endpoints.

# Decision
We chose Vertex AI Endpoints.

# Consequences
Positive:
- Reduced Ops Overhead: No need to manage NVIDIA drivers, CUDA versions, or node auto-scaling rules.
- Security: Native integration with IAM and VPC Service Controls.
- Scaling: Scale-to-zero capabilities are easier to configure out of the box.

Negative:
- Cost: Higher per-hour cost compared to spot instances on GKE.
- Control: Less granular control over the specific hardware/kernel optimizations.

## Mitigation
We will monitor costs weekly. If monthly spend exceeds $X, we will re-evaluate migrating to GKE Spot instances.