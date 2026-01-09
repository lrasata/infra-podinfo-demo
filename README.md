# infra-podinfo-demo 🚧 

>
> 	🚧 Construction in progress
>

This repository contains infrastructure-as-code and configuration for deploying the [podinfo](https://github.com/stefanprodan/podinfo) demo application on Google Kubernetes Engine (GKE), with supporting observability and Terraform modules.

## Project Structure

```
infra-podinfo-demo/
├── kubernetes/
│   ├── base/                # Base Kubernetes manifests (ingress, podinfo, etc.)
│   └── overlays/            # Environment-specific overlays (dev, staging, prod)
│       ├── dev/
│       ├── staging/
│       └── prod/
├── observability/
│   ├── grafana/             # Grafana configuration
│   ├── loki/                # Loki configuration
│   └── prometheus/          # Prometheus configuration
└── terraform/
	├── live/                # Live environment deployments
	│   ├── dev/
	│   ├── staging/
	│   └── prod/
	└── modules/             # Reusable Terraform modules (gke, iam, vpc)
```

## Getting Started

### Prerequisites
- [Terraform](https://www.terraform.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- Access to a Google Cloud Platform (GCP) project

### 1. Provision Infrastructure with Terraform

Navigate to the desired environment (e.g., `dev`):

```sh
cd terraform/live/dev
terraform init
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

This will provision the GKE cluster and supporting resources using the modules defined in `terraform/modules/`.

### 2. Deploy Kubernetes Resources

Update your kubeconfig to point to the new GKE cluster, then apply the manifests:

```sh
gcloud container clusters get-credentials <cluster-name> --region <region> --project <project-id>
kubectl apply -k kubernetes/overlays/dev
```

Replace `dev` with `staging` or `prod` as needed.

### 3. Set Up Observability

Apply the manifests in the `observability/` directory to deploy Grafana, Loki, and Prometheus:

```sh
kubectl apply -f observability/grafana/
kubectl apply -f observability/loki/
kubectl apply -f observability/prometheus/
```

## Folder Details

- **kubernetes/**: Kubernetes manifests and Kustomize overlays for different environments.
- **observability/**: Monitoring and logging stack configuration.
- **terraform/**: Infrastructure provisioning code, organized by environment and reusable modules.

## References
- [podinfo](https://github.com/stefanprodan/podinfo)
- [Terraform GKE Module](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest)

