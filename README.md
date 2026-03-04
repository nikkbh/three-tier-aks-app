# Three Tier App Deployed on AKS

A production-grade three-tier application (frontend, backend, database) deployed on Azure Kubernetes Service (AKS) with Application Gateway ingress, Key Vault integration, and PostgreSQL backend.

![System Flow](assets/image.png)

## 📋 Table of Contents

- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Deployment](#deployment)
- [CI/CD Pipeline](#cicd-pipeline)
- [Troubleshooting & RCAs](#troubleshooting--rcas)
- [Contributing](#contributing)

---

## 🏗️ Architecture

The application follows a three-tier microservices architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                   Azure Application Gateway                 │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              Ingress Controller (AGIC)              │  │
│  │  /          →  frontend:80  (nginx)                │  │
│  │  /api       →  backend:80   (Go API)               │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                    AKS Cluster (prod)                       │
│                                                             │
│  ┌──────────────────┐  ┌──────────────────┐              │
│  │  Frontend Pod    │  │  Backend Pod     │              │
│  │  (nginx + SPA)   │  │  (Go + Fiber)    │              │
│  │  Port: 80        │  │  Port: 8080      │              │
│  └──────────────────┘  └──────────────────┘              │
│           ↓                      ↓                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │         Azure Key Vault (Secrets)                 │  │
│  │  - DB Username                                   │  │
│  │  - DB Password                                   │  │
│  │  - DB Name                                       │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              Azure Database for PostgreSQL                  │
│                                                             │
│  - users table (CRUD operations)                      │
│  - UUID extension (uuid-ossp)                         │
└─────────────────────────────────────────────────────────────┘
```

### Components

| Component              | Technology                       | Purpose                           |
| ---------------------- | -------------------------------- | --------------------------------- |
| **Frontend**           | React + TypeScript + Nginx       | User interface (SPA)              |
| **Backend**            | Go + Fiber                       | REST API for CRUD operations      |
| **Database**           | Azure PostgreSQL                 | Persistent data storage           |
| **Container Registry** | Azure Container Registry (ACR)   | Private image repository          |
| **Ingress**            | Azure Application Gateway + AGIC | External traffic routing          |
| **Secrets**            | Azure Key Vault + CSI Driver     | Secure credential management      |
| **Infrastructure**     | Terraform                        | IaC for Azure resources           |
| **Orchestration**      | Kubernetes + Helm                | Container deployment & management |

---

## 📦 Prerequisites

- **Azure CLI**: `az --version`
- **kubectl**: `kubectl version --client`
- **Helm**: `helm version`
- **Terraform**: `terraform version`
- **Docker**: `docker --version`
- **Azure Subscription** with adequate quota for AKS, PostgreSQL, App Gateway
- **Service Principal** or **Azure CLI login** for Terraform

---

## 🚀 Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/your-org/three-tier-aks-app.git
cd three-tier-aks-app
```

### 2. Deploy infrastructure with Terraform

```bash
cd infra/terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

This will create:

- Resource Group
- Virtual Network & Subnets
- AKS Cluster
- Application Gateway
- Azure PostgreSQL Database
- Azure Key Vault
- Azure Container Registry

### 3. Configure kubectl

```bash
az aks get-credentials --resource-group rg-three-tier-aks --name aks-three-tier-app
kubectl config current-context
```

### 4. Create namespace

```bash
kubectl create namespace prod
```

### 5. Deploy Helm charts

```bash
# Backend
helm install backend ./manifests/helm/backend -n prod

# Frontend
helm install frontend ./manifests/helm/frontend -n prod
```

### 6. Verify deployment

```bash
kubectl get pods -n prod
kubectl get svc -n prod
kubectl get ingress -n prod
```

### 7. Access the application

```bash
# Get Application Gateway IP
APP_GW_IP=$(kubectl get ingress frontend -n prod -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Open in browser
echo "http://$APP_GW_IP"
```

---

## 📂 Project Structure

```
three-tier-aks-app/
├── frontend/                      # React SPA
│   ├── src/
│   │   ├── api/users.ts          # API client
│   │   ├── components/           # React components
│   │   └── types/                # TypeScript types
│   ├── nginx.conf                # Nginx reverse proxy config
│   └── Dockerfile
│
├── backend/                       # Go REST API
│   ├── cmd/
│   │   └── server/main.go        # Application entry point
│   ├── internal/
│   │   ├── handlers/             # Route handlers
│   │   ├── database/             # DB connection
│   │   └── config/               # Configuration
│   └── Dockerfile
│
├── manifests/                     # Kubernetes manifests
│   └── helm/
│       ├── backend/              # Backend Helm chart
│       │   ├── Chart.yaml
│       │   ├── values.yaml
│       │   └── templates/
│       └── frontend/             # Frontend Helm chart
│           ├── Chart.yaml
│           ├── values.yaml
│           └── templates/
│
├── infra/                         # Infrastructure as Code
│   └── terraform/
│       ├── main.tf               # Root module
│       ├── variables.tf
│       ├── outputs.tf
│       └── modules/              # Reusable modules
│           ├── aks-cluster/
│           ├── app-gateway/
│           ├── database/
│           └── key-vault/
│
├── Jenkinsfile                    # CI/CD pipeline
└── README.md
```

---

## UI Screenshots:

![UI](assets/UI.png)

## 🔄 Deployment

### Manual Deployment

#### Build & Push Images

```bash
# Frontend
cd frontend
docker build -t threetieracr25c33d3d.azurecr.io/frontend:v1.0.0 .
docker push threetieracr25c33d3d.azurecr.io/frontend:v1.0.0

# Backend
cd backend
docker build -t threetieracr25c33d3d.azurecr.io/backend:v1.0.0 .
docker push threetieracr25c33d3d.azurecr.io/backend:v1.0.0
```

#### Deploy with Helm

```bash
# Frontend
helm upgrade frontend ./manifests/helm/frontend -n prod \
  --set image.tag=v1.0.0 \
  --wait

# Backend
helm upgrade backend ./manifests/helm/backend -n prod \
  --set image.tag=v1.0.0 \
  --wait
```

#### Verify Rollout

```bash
kubectl rollout status deployment/frontend -n prod
kubectl rollout status deployment/backend -n prod
```

---

## 🔄 CI/CD Pipeline

### Jenkins Pipeline

A `Jenkinsfile` is included for automated builds and deployments. The pipeline:

1. Checks out code from Git
2. Builds frontend & backend Docker images
3. Pushes images to ACR (tagged with commit hash + `latest`)
4. Deploys via Helm charts
5. Verifies rollout status

#### Setup

1. Create Jenkins credentials:
   - `acr-credentials` — ACR username/password
   - `kubeconfig-prod` — Kubernetes config file

2. Create a Jenkins pipeline job pointing to this repo's `Jenkinsfile`

3. Trigger the pipeline on Git push (webhook)

#### Run Manually

```bash
# Build & push images
docker build -t <ACR>/frontend:latest ./frontend
docker push <ACR>/frontend:latest

# Deploy
helm upgrade frontend ./manifests/helm/frontend -n prod --set image.tag=latest
```

---

## 🔧 Configuration

### Environment Variables

Backend environment variables (set via Helm `values.yaml` or Kubernetes Secrets):

```yaml
DATABASE_URL: postgresql://user:password@db-host:5432/db-name
DATABASE_SSL_MODE: require
LOG_LEVEL: info
```

**Best Practice:** Use Azure Key Vault + CSI Driver instead of hardcoding values.

### Secrets Management

Secrets are stored in Azure Key Vault and mounted at runtime:

```bash
# View mounted secrets
kubectl exec -n prod <backend-pod> -- env | grep DB_
```

---

## 📊 Troubleshooting & RCAs

### 1. RCA – 502s from App Gateway to backend

**Symptoms** – frontend UI loaded but any API call (`/api/v1/...`) returned 502.  
Backend pod logs showed `GET /api → Cannot GET /api` even though cluster‑internal
`curl http://backend:80/api/v1/users` worked.

**Root cause** – AGIC creates a backend pool for each ingress and attaches a
health‑probe. By default the probe path is `/`. The backend service only serves
`/api/v1/*` (and a dedicated `/health` endpoint); there is no handler on `/`, so
every probe failed. The pool was marked unhealthy/empty and the gateway replied
502 to all requests, even though the service itself was reachable.

**Fix** – tell AGIC which path to probe (or add a `/` handler). We added the
annotation `appgw.ingress.kubernetes.io/health-probe-path: "/health"` to the
frontend ingress. AGIC then marked the backend pool healthy and traffic flowed normally.

**Lesson** – when using App Gateway/AGIC with path‑based routing, ensure the probe
path matches an actual endpoint in the service (or annotate it); otherwise the
gateway will drop requests with 502 despite the pods being fine.

---

### 2. RCA – ImagePullBackOff on startup

**Symptoms** – all deployments stalled with `ImagePullBackOff`/`ErrImagePull`
errors when AKS tried to fetch the container images from ACR.

**Root cause** – the Azure Container Registry had been granted the `AcrPull`
role to the _control‑plane_ managed identity instead of the **kubelet
identity** that actually performs the pulls. The nodes therefore had no
permissions to read the registry.

**Fix** – re‑attach the registry to the AKS cluster (or explicitly assign
`AcrPull` to the kubelet identity). Once the correct identity had access,
new pods were able to pull images and start normally.

**Lesson** – when using private registries with AKS, always ensure the **kubelet
identity** (not the control plane) has the pull role; otherwise you'll see
ImagePullBackOffs even though the cluster and registry are otherwise valid.

---

### 3. RCA – CrashLoopBackOffs from database/connect errors

**Symptoms** – the backend deployment never stayed up; pods entered
`CrashLoopBackOff`. Logs emitted messages about being "unable to connect to
Azure PostgresDB" despite a DNS lookup from a test pod returning an IP, and
later the application crashed while trying to create the `uuid‑ossp`
extension.

**Root cause** – two related issues:

- The cluster hadn't been allowed through the database's network rules
  (the connection string was correct and DNS resolved, but the server
  refused the TCP handshake), so every attempt to open a connection failed
  immediately.
- The startup code unconditionally executed `CREATE EXTENSION uuid‑ossp;`.
  Azure Database for PostgreSQL only permits extensions that are on its
  `azure.extensions` allow‑list; the server rejected the statement and the
  app panic'd, crashing the container.

**Fix** – update the PostgreSQL firewall/vnet rules to include the AKS
outbound range (or use a private endpoint) so the pod can reach the database,
and add `uuid-ossp` to the server's allowed‑extensions configuration ahead of
deployment. With network access and the extension pre‑provisioned the app
started successfully.

**Lesson** – always validate external service connectivity from inside the
cluster (DNS + firewall) and be mindful of managed‑service restrictions such
as permitted extensions; handle missing‑extension errors gracefully or
provision them as part of infrastructure setup.

---

### 4. RCA – 502 Bad Gateway after AKS cluster restart

**Symptoms** – after stopping and restarting the AKS cluster, all requests to both
`/` and `/api` returned 502 Bad Gateway, despite pods being in `Running` state
with healthy logs.

**Root cause** – when an AKS cluster is stopped, the underlying VMs are deallocated
and lose their IP addresses. Upon restart, Azure assigns **new node IPs**. Kubernetes
reschedules pods on these new nodes with new pod IPs, but the Application Gateway
Ingress Controller (AGIC) had cached the old pod IPs in its backend pools. The
gateway continued forwarding traffic to the stale pod endpoints that no longer
existed, causing every request to fail with 502.

**Fix** – force AGIC to reconcile and rediscover the current pod IPs by restarting
the AGIC deployment:

```bash
kubectl rollout restart deployment/ingress-appgw-deployment -n kube-system
kubectl rollout status deployment/ingress-appgw-deployment -n kube-system
```

After AGIC restarts (60–90 seconds), it queries the current pod IPs from
Kubernetes and reprograms the Application Gateway backend pools with the new
endpoints. Traffic then flows normally.

**Lesson** – AGIC caches pod endpoint IPs in the gateway; cluster infrastructure
changes (stop/start, node recreation, autoscaling) invalidate that cache.
Always restart AGIC after a cluster restart to force endpoint rediscovery, or
configure a shorter AGIC sync interval (`--reconcile-interval`) in production.

---

## 📋 Common Commands

### View Pods

```bash
kubectl get pods -n prod
kubectl describe pod <pod-name> -n prod
kubectl logs <pod-name> -n prod
```

### Port Forwarding

```bash
kubectl port-forward -n prod svc/backend 8080:80
kubectl port-forward -n prod svc/frontend 3000:80
```

### Helm Operations

```bash
helm list -n prod
helm values <release> -n prod
helm history <release> -n prod
helm rollback <release> <revision> -n prod
```

### View Ingress

```bash
kubectl get ingress -n prod
kubectl describe ingress frontend -n prod
```

---

## 🔐 Security Best Practices

- ✅ Use Azure Key Vault for all secrets
- ✅ Enable RBAC on AKS
- ✅ Use Network Policies for pod-to-pod communication
- ✅ Scan container images for vulnerabilities
- ✅ Use private ACR (not public) for images
- ✅ Enable audit logging on AKS
- ✅ Rotate secrets regularly

---

## 📚 Resources

- [AKS Documentation](https://learn.microsoft.com/en-us/azure/aks/)
- [Helm Charts](https://helm.sh/docs/)
- [Kubernetes Manifests](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Application Gateway Ingress Controller](https://azure.github.io/application-gateway-kubernetes-ingress/)

---

## 📝 License

This project is licensed under the MIT License – see the LICENSE file for details.

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -m 'Add improvement'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Open a Pull Request

---

## 📧 Support

For issues, questions, or feedback, please open a GitHub Issue or contact the maintainers.
