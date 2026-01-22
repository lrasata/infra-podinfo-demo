# infra-podinfo-demo 🚧

> 🚧 Construction in progress

![Setup GKE cluster](https://github.com/lrasata/infra-podinfo-demo/actions/workflows/setup-cluster.yaml/badge.svg)

## Overview

This project is my first hands-on experience with Kubernetes. It showcases a full end-to-end infrastructure setup using **Terraform, GKE, Kubernetes, Helm, NGINX Ingress, Grafana, and Prometheus**, all provisioned via a **GitHub Actions CI/CD pipeline**.

It is designed to be **educational, reusable, and production-ready** for learning, prototyping, or as a foundation for real-world workloads on GKE with modern DevOps practices.

## Project Goals & Architecture Rationale

This project is designed with **learning, best practices, and real-world relevance** in mind. It provides a hands-on, end-to-end example of deploying a cloud-native application on Kubernetes, while leveraging modern DevOps tooling.

### Why This Architecture?

* **GKE (Google Kubernetes Engine):**
  GKE makes Kubernetes **easy to use for beginners**. It abstracts away complex cluster setup and maintenance (“plumbing”), allowing you to **focus on learning Kubernetes concepts, deployments, and CI/CD workflows**.

* **Helm:**
  Helm is widely used in real-world projects for packaging and deploying Kubernetes applications. It **prevents the need to rewrite hundreds of YAML manifests** and provides a standard, maintainable approach to app deployment. Using Helm here gives you first-hand experience with professional-grade tooling.

* **NGINX Ingress:**
  To make web applications accessible externally, we use NGINX Ingress. It provides **routing, TLS, and authentication** capabilities for services exposed to the internet.

* **Prometheus, Grafana & ServiceMonitors:**
  Observability is a key part of production-ready deployments. Prometheus collects metrics, Grafana visualizes them, and ServiceMonitors simplify metric discovery. This setup gives you a **full monitoring stack** to track cluster health and application performance.

### Why This Project is Worth Exploring

This repository is **especially useful for beginners** who want a realistic introduction to Kubernetes and DevOps practices. By following it, you will:

* Learn **IaC with Terraform** for cloud infrastructure provisioning.
* Deploy **Kubernetes applications with Helm and overlays** for multiple environments.
* Set up **CI/CD pipelines with GitHub Actions** for automated deployments.
* Implement **observability with Prometheus and Grafana**, a crucial skill in production operations.
* Understand **best practices in security, scalability, and maintainability** from the start.

In short, it’s a **hands-on learning playground** that mirrors professional workflows without overwhelming complexity.

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
│   └── overlays/            # Environment-specific overlays (dev, staging)
│       ├── dev/
│       └── staging/
├── observability/
│   ├── grafana/             # Grafana configuration
│   └── prometheus/          # Prometheus configuration
└── terraform/
    ├── live/                # Live environment deployments
    │   ├── dev/
    │   └── staging/
    └── modules/             # Reusable Terraform modules (gke)
```

## Why separate clusters for each environment

For this demo project, we use **separate clusters for `dev` and `staging`**.

* This keeps each environment **fully isolated** — changes in dev cannot affect staging.
* It allows us to **reuse the same manifests** across environments without worrying about conflicts.
* Using separate clusters makes the setup **simpler for beginners**, as you don’t need to learn additional tools like Kustomize or Helm overlays at this stage.

> 💡 In a real-world project, you probably would use **Kustomize, Helm, or environment variables** to manage multiple environments in a single cluster. This is definitely something I plan to try as a **next step in the learning path**.


## Getting Started

This guide will help you **provision infrastructure, deploy the podinfo application, and access observability tools** using the CI/CD pipeline.

### Required Environment Variables for CI/CD Pipeline

The pipeline depends on a few environment variables, which you must set as **GitHub repository secrets** under **Settings > Secrets and variables > Actions**:

| Variable Name      | Description                                  | Example Value / Notes                                                      |
| ------------------ | -------------------------------------------- | -------------------------------------------------------------------------- |
| GCP_SA_KEY         | Google Cloud service account key (JSON)      | (Secret) JSON string                                                       |
| GCP_PROJECT_ID     | Google Cloud project ID                      | my-gcp-project-id                                                          |
| GKE_CLUSTER_NAME   | Name of the GKE cluster                      | my-gke-cluster                                                             |
| GCP_ZONE           | GCP zone for the cluster                     | us-central1-a                                                              |
| GCP_REGION         | GCP region for the cluster                   | us-central1                                                                |
| GRAFANA_BASIC_AUTH | Grafana Ingress basic auth (htpasswd output) | admin:$apr1$... // see [Observability Setup](#how-to-set-up-observability) |

### 1. Provision Infrastructure with Terraform

The GKE cluster, Kubernetes resources, and observability stack are **fully automated via GitHub Actions**.

* Trigger the pipeline manually from the **GitHub Actions tab** or use the workflow dispatch for your desired environment (dev, staging, prod).
* The pipeline will handle:

  * Creating the GKE cluster
  * Deploying the podinfo application via Kubernetes manifests/Helm
  * Setting up Prometheus, Grafana, and NGINX Ingress

> 💡 **Tip:** Using GKE with Terraform and GitHub Actions gives you a professional DevOps workflow without manual steps.

### 2. Setting Up Grafana Password

Before accessing Grafana, you need to generate a **basic auth password**:

1. Generate the credentials:

```sh
htpasswd -nb <username> <password>
```

This outputs a string like:

```
admin:$apr1$xyz123...
```

2. Save this as a **GitHub Actions secret**:

* Go to your repository → **Settings > Secrets and variables > Actions**
* Click **New repository secret**
* Name it `GRAFANA_BASIC_AUTH`
* Paste the generated string as the value

3. The pipeline will use this secret to create a Kubernetes secret for Grafana:

```sh
kubectl create secret generic grafana-basic-auth \
  --from-literal=auth="${GRAFANA_BASIC_AUTH}" \
  -n monitoring
```

### 3. Accessing Podinfo Application and Grafana

Once the deployment completes:

1. Configure kubectl for your cluster:

```sh
gcloud container clusters get-credentials <cluster-name> --zone <zone> --project <project-id>
```

2. Get the external IP of the Ingress:

```sh
kubectl get ingress -n podinfo
```

3. Open your browser:

```
http://<EXTERNAL_IP>/      # Podinfo application
http://<EXTERNAL_IP>/grafana/  # Grafana dashboard
```

* Replace `<EXTERNAL_IP>` with the `ADDRESS` value from the previous command.
* Log in to Grafana using the **username/password** you generated in the previous step.
* On the grafana dashboard, you can retrieve the username/password from Kubernetes (this is not same set of credentials as previous step):

```sh
kubectl get secret monitoring-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode
```

### 4. Accessing Prometheus UI

To inspect metrics collected from your cluster and app:

```sh
kubectl port-forward svc/prometheus -n monitoring 9090:9090
```

Then open your browser:

```
http://localhost:9090
```

This gives you full access to the **Prometheus dashboard**.

## References

* [podinfo](https://github.com/stefanprodan/podinfo)
* [Terraform GKE Module](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest)
