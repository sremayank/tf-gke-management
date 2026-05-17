# Architecture

## Context

The platform modernisation replaces manually administered, project-local GKE clusters with a managed multi-cluster foundation. Terraform owns repeatable infrastructure, Fleet provides a governance plane, and Workload Identity removes long-lived service account keys from workloads.

## Platform Layers

| Layer | Responsibility |
| --- | --- |
| Network | Dedicated VPC, regional subnets, secondary IP ranges, NAT, and firewall baseline. |
| Cluster | Private GKE clusters with hardened nodes, managed upgrades, Workload Identity, and observability. |
| Governance | Fleet membership, Policy Controller, and Config Sync integration points. |
| Identity | Kubernetes service account to Google service account bindings with narrow IAM roles. |
| Operations | Monitoring policies, runbooks, CI gates, and environment promotion. |

## Key Decisions

1. **Private regional clusters by default**
   Regional control planes and private nodes improve availability and reduce public exposure.

2. **Fleet-first governance**
   Fleet membership gives the platform team a common control plane for policy and configuration across clusters.

3. **Environment-owned composition**
   Modules remain generic. The `live/*` directories express environment-specific sizing, CIDRs, labels, and operational posture.

4. **Workload Identity only**
   Workloads receive Google Cloud access through Kubernetes service accounts. Static keys are intentionally excluded.

## Production Topology

Production demonstrates two GKE clusters registered into the same Fleet: a primary cluster in the main region and a secondary cluster for resilience. Both receive the same policy baseline while keeping node-pool capacity independently tunable.
