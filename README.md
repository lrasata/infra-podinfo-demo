# infra-podinfo-demo 🚧

> 🚧 Construction in progress

![Setup GKE cluster](https://github.com/lrasata/infra-podinfo-demo/actions/workflows/setup-cluster.yaml/badge.svg)

## Overview

This project is my first hands-on experience with Kubernetes. It showcases a full end-to-end infrastructure setup using **Terraform, GKE, Kubernetes, Helm, NGINX Ingress, Grafana, and Prometheus**, all provisioned via a **GitHub Actions CI/CD pipeline**.

It is designed to be **educational, reusable, and production-ready** for learning, prototyping, or as a foundation for real-world workloads on GKE with modern DevOps practices.

## Key Features

* **Production-Ready Patterns:** Implements cloud-native best practices with declarative IaC, environment overlays, and automated CI/CD.
* **Scalability & Flexibility:** Easily extendable to more environments, services, or cloud providers.
* **Built-In Observability:** Prometheus and Grafana are deployed for monitoring and logging, providing rapid insights and troubleshooting.
* **Security:** Grafana Ingress is secured with basic auth, and secrets are managed via GitHub Actions and Kubernetes.
* **Learning & Reusability:** Serves as a reference for real-world GKE deployments, Terraform usage, and Kubernetes operations. Can be adapted for other apps or teams.

## Architecture Overview

This project provisions a **GKE cluster using Terraform** and deploys the [podinfo](https://github.com/stefanprodan/podinfo) demo application with Kubernetes manifests and Helm. It also sets up an **observability stack** (Prometheus & Grafana) and a secure NGINX Ingress.

![Podinfo-demo diagram](./docs/podinfo-demo.png "Cluster Diagram")


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
│   └── prometheus/          # Prometheus configuration
└── terraform/
    ├── live/                # Live environment deployments
    │   ├── dev/
    │   ├── staging/
    │   └── prod/
    └── modules/             # Reusable Terraform modules (gke)
```

## Getting Started

### Required Environment Variables for CI/CD Pipeline

| Variable Name      | Description                                  | Example Value / Notes                                      |
| ------------------ | -------------------------------------------- | ---------------------------------------------------------- |
| GCP_SA_KEY         | Google Cloud service account key (JSON)      | (Secret) JSON string                                       |
| GCP_PROJECT_ID     | Google Cloud project ID                      | my-gcp-project-id                                          |
| GKE_CLUSTER_NAME   | Name of the GKE cluster                      | my-gke-cluster                                             |
| GCP_ZONE           | GCP zone for the cluster                     | us-central1-a                                              |
| GCP_REGION         | GCP region for the cluster                   | us-central1                                                |
| GRAFANA_BASIC_AUTH | Grafana Ingress basic auth (htpasswd output) | admin:$apr1$... // see section How to Set Up Observability |

These variables must be set as GitHub repository secrets for the pipeline to run successfully. You can configure them in your repository under **Settings > Secrets and variables > Actions**.

### 1. Provision Infrastructure with Terraform

To provision the GKE cluster and all supporting resources, simply run the CI/CD pipeline provided in this repository. The pipeline will automatically handle infrastructure creation, application deployment, and observability setup for you.

You can trigger the pipeline manually from the GitHub Actions tab, or by using the workflow dispatch feature for your desired environment (e.g., dev, staging, prod).

### 2. Accessing Podinfo Application

After deployment, you can access your app via the Ingress external IP:

1. Get the external IP of the Ingress:

```sh
gcloud container clusters get-credentials <cluster-name> --region <region> --project <project-id>
kubectl get ingress -n dev
```

2. Find the `ADDRESS` column in the output. This is your app's external IP.

3. Open your browser and visit:

```
http://<EXTERNAL_IP>/app/ # podinfo app
```

Replace `<EXTERNAL_IP>` with the value from step 2.

For Grafana:

```
http://<EXTERNAL_IP>/grafana/ # Grafana dashboard
```

* Replace `<EXTERNAL_IP>` with the value from step 2
* Enter the username and password generated via htpasswd during the [Observability Set Up](#how-to-set-up-observability)
* To retrieve Grafana admin password:

  ```sh
  kubectl get secret monitoring-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode
  ```

## How to Set Up Observability

### Grafana Ingress Basic Auth Setup

#### 1. Generate Basic Auth Credentials

```sh
htpasswd -nb <username> <password>
```

This will output a string like `user:$apr1$...`.

#### 2. Set Up GitHub Actions Secret

* Go to your repository on GitHub
* Navigate to **Settings** > **Secrets and variables** > **Actions**
* Click **New repository secret**
* Name the secret: `GRAFANA_BASIC_AUTH`
* Paste the generated value as the secret value

#### 3. Reference the Secret in GitHub Actions

```yaml
env:
  GRAFANA_BASIC_AUTH: ${{ secrets.GRAFANA_BASIC_AUTH }}
```

Use this value when creating the Kubernetes secret for Grafana Ingress basic auth:

```sh
kubectl create secret generic grafana-basic-auth \
  --from-literal=auth="${GRAFANA_BASIC_AUTH}" \
  -n monitoring
```

## References

* [podinfo](https://github.com/stefanprodan/podinfo)
* [Terraform GKE Module](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest)
