#!/bin/bash
# Lab 04 - Test Connectivity
# Description: Validates external and internal services

set -e

echo "========================================="
echo " Testing AKS Services"
echo "========================================="

# Wait for external IP
echo "[1/4] Waiting for external LoadBalancer IP..."
echo "This may take 2-3 minutes..."
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress[0].ip}' \
    service/nginxexternal --timeout=300s 2>/dev/null || true

# Get IPs
EXTERNAL_IP=$(kubectl get service nginxexternal -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
INTERNAL_IP=$(kubectl get service nginxinternal -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo ""
echo "[2/4] Service IP Addresses:"
echo "External Service (Public):  $EXTERNAL_IP"
echo "Internal Service (Private): $INTERNAL_IP"

# Test external service
echo ""
echo "[3/4] Testing external service (public access)..."
if curl -s -o /dev/null -w "%{http_code}" http://$EXTERNAL_IP | grep -q "200"; then
    echo "✅ External service accessible from Internet"
    echo "Response:"
    curl -s http://$EXTERNAL_IP
else
    echo "❌ External service not accessible"
fi

# Test internal service
echo ""
echo "[4/4] Testing internal service (private access)..."
echo "Note: This should only work from within the VNet"
echo "Testing from Internet (should timeout)..."
if timeout 5 curl -s http://$INTERNAL_IP 2>/dev/null; then
    echo "⚠️  Warning: Internal service accessible from Internet (unexpected)"
else
    echo "✅ Internal service NOT accessible from Internet (expected)"
    echo "Internal service is properly isolated to VNet only"
fi

# Show pod info
echo ""
echo "========================================="
echo " Pod Information"
echo "========================================="
kubectl get pods -o wide

echo ""
echo "========================================="
echo " Load Balancer Status"
echo "========================================="
kubectl get services

echo ""
echo "========================================="
echo " Test Complete!"
echo "========================================="
echo "External URL: http://$EXTERNAL_IP"
echo "Internal IP:  $INTERNAL_IP (VNet only)"
echo ""
echo "To test internal service from VNet:"
echo "  1. Deploy a test pod in AKS"
echo "  2. Run: kubectl run -it --rm test --image=busybox -- sh"
echo "  3. Run: wget -qO- http://$INTERNAL_IP"
echo "========================================="
```

---

## 🎨 **Prompt Napkin.ai pour Diagram**
```
Create Azure architecture diagram for "AKS with ACR Security":

COMPONENTS (left to right):

1. Developer Workstation (left)
   - Icon: laptop
   - Label: "Developer"
   - Actions: Build image, Push to ACR

2. Azure Container Registry (center-left)
   - Icon: container/registry
   - Label: "Azure Container Registry (ACR)"
   - Contains: "nginx:v1 image"
   - Badge: "Private registry"
   - Note: "Admin disabled"

3. Azure Kubernetes Service (center-right)
   - Icon: Kubernetes logo/hexagon
   - Label: "AKS Cluster"
   - Shows 2 nodes
   - Network: Azure CNI
   - Inside show:
     * nginxexternal pods (2 replicas)
     * nginxinternal pods (2 replicas)

4. Load Balancers (right)
   - External LB:
     * Icon: cloud with arrow
     * Public IP: 20.x.x.x
     * Label: "External LoadBalancer"
     * Accessible: Internet (globe icon)
   
   - Internal LB:
     * Icon: shield/lock
     * Private IP: 10.240.x.x
     * Label: "Internal LoadBalancer"
     * Accessible: VNet only

5. Managed Identity (floating, center)
   - Icon: key/identity badge
   - Label: "AKS Managed Identity"
   - Shows connection to ACR
   - Note: "acrpull role"

DATA FLOW:

1. Developer → ACR
   - Arrow: "Push image"
   - Command: "az acr build"

2. AKS → ACR (via Managed Identity)
   - Arrow: "Pull image"
   - Label: "Authenticated via Managed Identity"
   - Color: green (secure)

3. External LB → nginxexternal pods
   - Arrow: bidirectional
   - Label: "Public traffic"
   - Color: orange

4. Internal LB → nginxinternal pods
   - Arrow: bidirectional
   - Label: "VNet traffic only"
   - Color: blue

SECURITY ANNOTATIONS:

- ACR box: 
  * "✅ No admin credentials"
  * "✅ Private registry"
  * "✅ Defender scanning"

- Managed Identity box:
  * "✅ No secrets in cluster"
  * "✅ Auto rotation"
  * "✅ RBAC integrated"

- AKS box:
  * "✅ Azure CNI networking"
  * "✅ Pod-level IPs"
  * "✅ NSG applicable"

- Internal LB:
  * "✅ Private IP only"
  * "❌ No Internet access"

CALLOUT BOX (bottom):
"Azure CNI Benefits:
- Pods get VNet IPs
- NSG rules apply to pods
- No NAT overhead
- Direct VM-to-pod communication"

STYLE:
- Azure blue theme
- Modern, clean design
- Security elements in green
- Public access in orange
- Private access in blue
- Include Azure service icons
- Professional spacing

TITLE: "Lab 04: AKS with ACR - Secure Container Deployment"
SUBTITLE: "Managed Identity + Azure CNI + Network Isolation"
