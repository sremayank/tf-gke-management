# Runbook: GKE Platform Incident Response

## Triage

1. Identify whether impact is control plane, nodes, workload scheduling, ingress, DNS, or identity.
2. Check Cloud Monitoring alerts and recent Terraform changes.
3. Confirm whether the issue affects one cluster or the whole Fleet.
4. Inspect node pool health and quota pressure.
5. Review Policy Controller denials for sudden admission failures.

## Common Actions

- Scale tenant node pools when pending pods are caused by capacity.
- Disable a newly introduced policy constraint only after confirming blast radius.
- Move traffic to the secondary cluster when application routing supports failover.
- Escalate to Google Cloud support for regional control plane degradation.

## Communication

Send updates with:

- Customer impact
- Affected clusters and namespaces
- Current mitigation
- Next checkpoint time
- Whether data integrity is at risk
