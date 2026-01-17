# infra-podinfo-demo 🚧 

>
> 	🚧 Construction in progress
>

![Setup GKE cluster](https://github.com/lrasata/infra-podinfo-demo/actions/workflows/setup-cluster.yaml/badge.svg)

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

#### Accessing Your Application

After deployment, you can access your app via the Ingress external IP:

1. Get the external IP of the Ingress:
	```sh
	gcloud container clusters get-credentials <cluster-name> --region <region> --project <project-id>
	kubectl get ingress -n dev
	```
	(or use the appropriate namespace)

2. Find the ADDRESS column in the output. This is your app's external IP.

3. Open your browser and visit:
	```
	http://<EXTERNAL_IP>/
	```
	(Replace <EXTERNAL_IP> with the value from step 2)

If you don’t see an IP, wait a few minutes and check again.

### 3. Set Up Observability

#### Grafana Ingress Basic Auth Setup

To secure the Grafana Ingress with basic authentication, follow these steps:

##### 1. Generate Basic Auth Credentials

You can generate a basic auth string using `htpasswd` (from the `apache2-utils` package) or with OpenSSL:

**Using htpasswd:**
```sh
htpasswd -nb <username> <password>
```
This will output a string like `user:$apr1$...`.

**Using OpenSSL (alternative):**
```sh
echo -n '<username>:<password>' | openssl base64
```
This outputs a base64-encoded string for use in basic auth.

##### 2. Set Up GitHub Actions Secret

Add the generated basic auth string as a secret in your GitHub repository:

- Go to your repository on GitHub
- Navigate to **Settings** > **Secrets and variables** > **Actions**
- Click **New repository secret**
- Name the secret: `GRAFANA_BASIC_AUTH`
- Paste the generated value as the secret value

##### 3. Reference the Secret in GitHub Actions

In your GitHub Actions workflow (e.g., `setup-cluster.yaml`), reference the secret as an environment variable:

```yaml
env:
	GRAFANA_BASIC_AUTH: ${{ secrets.GRAFANA_BASIC_AUTH }}
```

Use this value when creating the Kubernetes secret for Grafana Ingress basic auth, for example:

```sh
kubectl create secret generic grafana-basic-auth \
	--from-literal=auth="${GRAFANA_BASIC_AUTH}" \
	-n monitoring
```

Or, in your deployment scripts, ensure the secret is created using the value from the GitHub Actions environment.

## Folder Details

- **kubernetes/**: Kubernetes manifests and Kustomize overlays for different environments.
- **observability/**: Monitoring and logging stack configuration.
- **terraform/**: Infrastructure provisioning code, organized by environment and reusable modules.

## References
- [podinfo](https://github.com/stefanprodan/podinfo)
- [Terraform GKE Module](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest)

