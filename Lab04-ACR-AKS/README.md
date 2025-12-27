# Lab 04: Azure Container Registry & Azure Kubernetes Service Security

## 🎯 Objective

Deploy a secure containerized application using **Azure Container Registry (ACR)** as a private image repository and **Azure Kubernetes Service (AKS)** with managed identities for authentication. Demonstrate network isolation with internal and external load balancers.

## 🏗️ Architecture

![Architecture Diagram](./diagrams/acr-aks-security-architecture.png)

### Components:
- **Azure Container Registry (ACR)**: Private Docker image repository
- **Azure Kubernetes Service (AKS)**: Managed Kubernetes cluster
- **Managed Identity**: Secure ACR integration (no credentials stored)
- **Azure CNI Networking**: Pod-level network policies
- **Load Balancers**: 
  - External (public): nginxexternal service
  - Internal (private): nginxinternal service

### Security Features:
- ✅ ACR authentication via Managed Identity (no credentials)
- ✅ Private container registry (no public DockerHub)
- ✅ Network isolation (internal LoadBalancer)
- ✅ Azure CNI for granular network control
- ✅ NSG policies applicable to pods directly

---

## 📋 Prerequisites

- Azure subscription with Contributor access
- Azure CLI installed (`az version` ≥ 2.50)
- kubectl installed
- Docker installed (optional, for local testing)
- Bash shell (Linux/macOS/WSL)

---

## 🔧 Lab Setup

### Task 1: Create Azure Container Registry (ACR)
```bash
# See scripts/01-setup-acr.sh

# Variables
RG_NAME="AZ500LAB04"
LOCATION="eastus"
ACR_NAME="acraz500$RANDOM"  # Must be globally unique

# Create Resource Group
az group create \
    --name $RG_NAME \
    --location $LOCATION

# Create Azure Container Registry (Basic SKU)
az acr create \
    --resource-group $RG_NAME \
    --name $ACR_NAME \
    --sku Basic \
    --admin-enabled false

# Build and push nginx image to ACR
az acr build \
    --registry $ACR_NAME \
    --image nginx:v1 \
    --file - <<EOF
FROM nginx:alpine
RUN echo '<h1>Hello from AKS - Secured with ACR</h1>' > /usr/share/nginx/html/index.html
EXPOSE 80
EOF

# Verify image in ACR
az acr repository list --name $ACR_NAME --output table
az acr repository show-tags --name $ACR_NAME --repository nginx --output table

# Expected output:
# Repository    Tag
# ----------    ---
# nginx         v1
```

**Key Security Features**:
- ✅ `--admin-enabled false`: No admin credentials (uses Managed Identity)
- ✅ Private registry: Images not exposed to public DockerHub
- ✅ Image scanning: Defender for Containers can scan ACR images

---

### Task 2: Create Azure Kubernetes Service (AKS)
```bash
# See scripts/02-setup-aks.sh

AKS_CLUSTER_NAME="AKSCluster"
NODE_COUNT=2
NODE_SIZE="Standard_DS2_v2"

# Create AKS cluster with Azure CNI networking
az aks create \
    --resource-group $RG_NAME \
    --name $AKS_CLUSTER_NAME \
    --node-count $NODE_COUNT \
    --node-vm-size $NODE_SIZE \
    --network-plugin azure \
    --generate-ssh-keys \
    --enable-managed-identity

# Integrate AKS with ACR (configures Managed Identity)
az aks update \
    --resource-group $RG_NAME \
    --name $AKS_CLUSTER_NAME \
    --attach-acr $ACR_NAME

# Get AKS credentials
az aks get-credentials \
    --resource-group $RG_NAME \
    --name $AKS_CLUSTER_NAME \
    --overwrite-existing

# Verify connection
kubectl get nodes

# Expected output:
# NAME                                STATUS   ROLES   AGE   VERSION
# aks-nodepool1-12345678-vmss000000   Ready    agent   2m    v1.27.7
# aks-nodepool1-12345678-vmss000001   Ready    agent   2m    v1.27.7
```

**Key Configuration**:
- `--network-plugin azure`: **Azure CNI** (vs kubenet)
  - Each pod gets IP from VNet subnet
  - NSG rules can filter pod traffic directly
  - Better integration with Azure networking

- `--enable-managed-identity`: **Managed Identity** (vs Service Principal)
  - Automatic credential rotation
  - No secrets stored in cluster
  - Simplified RBAC integration

- `--attach-acr`: **Automatic ACR Integration**
  - Assigns `acrpull` role to AKS Managed Identity
  - Pods can pull images without credentials
  - Secure and seamless

---

### Task 3: Deploy External Service (Public Load Balancer)
```yaml
# See scripts/03-deploy-services.yaml

# nginxexternal-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginxexternal
  labels:
    app: nginxexternal
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginxexternal
  template:
    metadata:
      labels:
        app: nginxexternal
    spec:
      containers:
      - name: nginx
        image: <ACR_NAME>.azurecr.io/nginx:v1
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: nginxexternal
spec:
  type: LoadBalancer
  selector:
    app: nginxexternal
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

**Deploy**:
```bash
# Replace ACR_NAME in YAML
export ACR_NAME=$(az acr list -g $RG_NAME --query "[0].name" -o tsv)
sed "s/<ACR_NAME>/$ACR_NAME/g" nginxexternal-deployment.yaml | kubectl apply -f -

# Wait for public IP assignment (may take 2-3 minutes)
kubectl get service nginxexternal --watch

# Expected output:
# NAME            TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)        AGE
# nginxexternal   LoadBalancer   10.0.123.45    20.115.67.89     80:31234/TCP   3m
```

**Test**:
```bash
EXTERNAL_IP=$(kubectl get service nginxexternal -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$EXTERNAL_IP

# Expected output:
# <h1>Hello from AKS - Secured with ACR</h1>
```

---

### Task 4: Deploy Internal Service (Private Load Balancer)
```yaml
# nginxinternal-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginxinternal
  labels:
    app: nginxinternal
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginxinternal
  template:
    metadata:
      labels:
        app: nginxinternal
    spec:
      containers:
      - name: nginx
        image: <ACR_NAME>.azurecr.io/nginx:v1
        ports:
        - containerPort: 80
        env:
        - name: MESSAGE
          value: "Internal Service"
---
apiVersion: v1
kind: Service
metadata:
  name: nginxinternal
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
spec:
  type: LoadBalancer
  selector:
    app: nginxinternal
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

**Key Annotation**:
```yaml
annotations:
  service.beta.kubernetes.io/azure-load-balancer-internal: "true"
```
- Creates **Azure Internal Load Balancer**
- Private IP from AKS VNet subnet
- Accessible only from within VNet (or peered networks)
- NOT exposed to Internet

**Deploy**:
```bash
sed "s/<ACR_NAME>/$ACR_NAME/g" nginxinternal-deployment.yaml | kubectl apply -f -

# Get internal IP (from VNet subnet)
kubectl get service nginxinternal

# Expected output:
# NAME            TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
# nginxinternal   LoadBalancer   10.0.234.56    10.240.0.10    80:32456/TCP   2m
#                                                ^^^^^^^^^^^
#                                                Private IP from VNet
```

**Test** (from VM in same VNet or via Bastion):
```bash
INTERNAL_IP=$(kubectl get service nginxinternal -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$INTERNAL_IP

# Expected output:
# <h1>Hello from AKS - Secured with ACR</h1>

# Test from Internet (should fail)
curl http://$INTERNAL_IP --connect-timeout 5
# curl: (28) Connection timed out
```

---

## ✅ Validation

### Test 1: ACR Integration (No Credentials)
```bash
# Verify Managed Identity has acrpull role
ACR_ID=$(az acr show -n $ACR_NAME -g $RG_NAME --query id -o tsv)
IDENTITY_PRINCIPAL_ID=$(az aks show -n $AKS_CLUSTER_NAME -g $RG_NAME --query identityProfile.kubeletidentity.objectId -o tsv)

az role assignment list \
    --scope $ACR_ID \
    --assignee $IDENTITY_PRINCIPAL_ID \
    --query "[?roleDefinitionName=='AcrPull'].{Role:roleDefinitionName,Principal:principalName}" \
    -o table

# Expected output:
# Role      Principal
# --------  ---------------------------------
# AcrPull   AKSCluster-agentpool
```

**Validation**: 
- ✅ No credentials in Kubernetes secrets
- ✅ Pods pull images seamlessly
- ✅ Automatic credential rotation

---

### Test 2: Network Isolation
```bash
# Get pod IPs
kubectl get pods -o wide

# Expected output shows pods have VNet IPs:
# NAME                             READY   STATUS    IP            NODE
# nginxexternal-7d8f9c5b6d-abc12   1/1     Running   10.240.0.15   aks-node-1
# nginxexternal-7d8f9c5b6d-def34   1/1     Running   10.240.0.16   aks-node-2
# nginxinternal-5c7a8d4e9f-ghi56   1/1     Running   10.240.0.17   aks-node-1
# nginxinternal-5c7a8d4e9f-jkl78   1/1     Running   10.240.0.18   aks-node-2

# NSG can now filter traffic to these pod IPs directly
# (not possible with kubenet)
```

**Azure CNI Benefits**:
- ✅ Pod IPs routable in VNet
- ✅ NSG rules apply to pods
- ✅ Direct VM-to-pod communication
- ✅ Better Azure network integration

---

### Test 3: External vs Internal Load Balancer
```bash
# External LB (public IP)
kubectl get service nginxexternal -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
# Output: 20.115.67.89 (public IP, Internet-routable)

# Internal LB (private IP)
kubectl get service nginxinternal -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
# Output: 10.240.0.10 (private IP, VNet only)

# Test external (from anywhere)
curl -I http://20.115.67.89
# HTTP/1.1 200 OK

# Test internal (from Internet - should fail)
curl -I http://10.240.0.10 --connect-timeout 5
# curl: (28) Connection timed out

# Test internal (from VNet VM - should work)
# (requires VM in same VNet or peered VNet)
```

---

### Test 4: Image Pull Verification
```bash
# Describe pod to see image pull events
kubectl describe pod -l app=nginxexternal | grep -A5 Events

# Expected output (no ImagePullBackOff):
# Events:
#   Type    Reason     Age   From               Message
#   ----    ------     ----  ----               -------
#   Normal  Scheduled  5m    default-scheduler  Successfully assigned default/nginxexternal-xxx to aks-node-1
#   Normal  Pulling    5m    kubelet            Pulling image "acraz500xxxxx.azurecr.io/nginx:v1"
#   Normal  Pulled     4m    kubelet            Successfully pulled image
#   Normal  Created    4m    kubelet            Created container nginx
#   Normal  Started    4m    kubelet            Started container nginx
```

**Validation**:
- ✅ Image pulled from private ACR
- ✅ No authentication errors
- ✅ Managed Identity working

---

## 🔐 Security Architecture

### Defense-in-Depth Layers:

**Layer 1: Image Security**
- ✅ Private registry (ACR) - no public DockerHub
- ✅ Image scanning with Defender for Containers
- ✅ Vulnerability assessment before deployment

**Layer 2: Authentication**
- ✅ Managed Identity (no credentials stored)
- ✅ Automatic credential rotation
- ✅ Azure RBAC integration

**Layer 3: Network Security**
- ✅ Azure CNI: Pod-level network isolation
- ✅ Internal Load Balancer: Private-only services
- ✅ NSG rules applicable to pods
- ✅ Network Policies (optional, can be added)

**Layer 4: Cluster Security**
- ✅ AKS Managed Control Plane (Azure-managed)
- ✅ Node auto-upgrade
- ✅ Pod Security Standards (can be enforced)

---

## 🎓 Key Concepts

### Azure CNI vs Kubenet

| Feature | Azure CNI | Kubenet |
|---------|-----------|---------|
| **Pod IP Source** | VNet subnet | Node internal NAT |
| **IP Consumption** | High (1 IP per pod) | Low (1 IP per node) |
| **NSG Support** | ✅ Direct pod filtering | ❌ Only node filtering |
| **Performance** | ⭐⭐⭐ Faster (no NAT) | ⭐⭐ NAT overhead |
| **VNet Integration** | ✅ Full | ⚠️ Limited |
| **Use Case** | **Production** | Dev/test (cost savings) |

**Lab 04 uses Azure CNI for production-grade security** ✅

---

### Managed Identity vs Service Principal

| Feature | Managed Identity (Lab 04) | Service Principal |
|---------|---------------------------|-------------------|
| **Credential Storage** | ✅ None (Azure-managed) | ❌ Secret in cluster |
| **Rotation** | ✅ Automatic | ❌ Manual (90 days) |
| **Security** | ⭐⭐⭐ Best | ⭐⭐ Moderate |
| **Complexity** | ✅ Simple | ⚠️ Complex |
| **Recommended** | **✅ Always** | Legacy only |

---

### Internal vs External Load Balancer

| Type | External LB | Internal LB |
|------|-------------|-------------|
| **IP Type** | Public (Azure-assigned) | Private (VNet subnet) |
| **Accessibility** | Internet | VNet only |
| **Use Case** | Public-facing apps | Internal APIs, databases |
| **Annotation** | None (default) | `service.beta.kubernetes.io/azure-load-balancer-internal: "true"` |
| **Security** | ⚠️ Exposed | ✅ Isolated |

**Best Practice**: 
- Frontend apps → External LB
- Backend APIs → Internal LB
- Databases → Internal LB + Private Endpoint

---

## 🛠️ Skills Demonstrated

- Azure Container Registry (ACR) configuration
- Azure Kubernetes Service (AKS) deployment
- Managed Identity integration (ACR pull)
- Azure CNI networking (pod-level IPs)
- Kubernetes Deployments and Services
- Internal and External Load Balancers
- Container image building and pushing
- kubectl cluster management
- Bash scripting for Azure automation

---

## 🎯 MITRE ATT&CK Mapping

### Techniques Mitigated:

**T1611 - Escape to Host**
- Mitigation: Container runtime isolation in AKS
- Defense: Pod Security Standards can be enforced

**T1552.007 - Container API**
- Mitigation: Managed Identity (no credentials in cluster)
- Defense: ACR authentication via Azure AD

**T1190 - Exploit Public-Facing Application**
- Mitigation: Internal Load Balancer for backend services
- Defense: Only frontend exposed to Internet

**T1610 - Deploy Container**
- Detection: ACR image scanning detects malicious images
- Defense: Only signed/scanned images deployed

**T1525 - Implant Internal Image**
- Mitigation: Private ACR (no public DockerHub)
- Defense: Defender for Containers scans ACR

---

## 💡 Real-World Architecture Pattern

### Three-Tier Web Application:
```
Internet
   │
   ▼
┌─────────────────────┐
│ External LB         │ Public IP: 20.x.x.x
│ (Frontend: React)   │ Service: nginxexternal
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Internal LB         │ Private IP: 10.240.0.10
│ (Backend: Node.js)  │ Service: apiinternal
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Internal LB         │ Private IP: 10.240.0.20
│ (Database: MongoDB) │ Service: dbinternal
└─────────────────────┘

All services pull images from private ACR via Managed Identity
```

**Lab 04 demonstrates this pattern** with nginxexternal (frontend) and nginxinternal (backend).

---

## 📚 Additional Resources

- [AKS Best Practices](https://learn.microsoft.com/en-us/azure/aks/best-practices)
- [Azure CNI Documentation](https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni)
- [ACR Authentication Options](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-authentication)
- [Internal Load Balancer in AKS](https://learn.microsoft.com/en-us/azure/aks/internal-lb)

---

## 🧹 Cleanup
```bash
# Delete AKS cluster (takes ~5 minutes)
az aks delete \
    --resource-group $RG_NAME \
    --name $AKS_CLUSTER_NAME \
    --yes --no-wait

# Delete ACR
az acr delete \
    --resource-group $RG_NAME \
    --name $ACR_NAME \
    --yes

# Delete Resource Group (removes all resources)
az group delete \
    --name $RG_NAME \
    --yes --no-wait
```

---

## 📝 Notes

### Azure CNI IP Planning:
- Each pod consumes 1 IP from VNet subnet
- Formula: `max_pods_per_node × node_count + nodes + services`
- Example: `30 pods/node × 3 nodes + 3 nodes + 10 services = 103 IPs`
- **Plan subnet size accordingly** (e.g., /24 = 256 IPs)

### ACR Performance Tiers:
- **Basic**: $5/month, 10 GB storage, 10 webhooks
- **Standard**: $20/month, 100 GB storage, 100 webhooks
- **Premium**: $50/month, 500 GB storage, geo-replication, Private Link

### AKS Node Sizes:
- **Dev/Test**: Standard_B2s (2 vCPU, 4 GB RAM)
- **Production**: Standard_DS2_v2 (2 vCPU, 7 GB RAM) - Lab 04
- **High-Performance**: Standard_D4s_v3 (4 vCPU, 16 GB RAM)

---

**Lab Status**: ✅ Completed  
**Documentation**: README + Scripts + YAML manifests  
**MITRE Mapping**: Included  
**Difficulty**: ⭐⭐⭐ (Intermediate)
