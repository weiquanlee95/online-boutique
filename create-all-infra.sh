#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================================"
echo "  Online Boutique - Full Infrastructure Setup"
echo "============================================================"
echo

# ---------------------------------------------------------------
# STEP 1: Create VPC
# ---------------------------------------------------------------
echo "==============================="
echo "STEP 1: Create VPC using Terraform"
echo "==============================="
cd "$SCRIPT_DIR/01_EKS_cluster_environment/01_VPC_terraform-manifests"
terraform init
terraform apply -auto-approve
echo "✅ VPC created successfully!"

# ---------------------------------------------------------------
# STEP 2: Create EKS Cluster with Addons
# ---------------------------------------------------------------
echo
echo "==============================="
echo "STEP 2: Create EKS Cluster using Terraform"
echo "==============================="
cd "$SCRIPT_DIR/01_EKS_cluster_environment/02_EKS_terraform-manifests_with_addons"
terraform init
terraform apply -auto-approve
echo "✅ EKS Cluster created successfully!"

# ---------------------------------------------------------------
# STEP 3: Configure kubeconfig
# ---------------------------------------------------------------
# echo
# echo "==============================="
# echo "STEP 3: Configure kubeconfig"
# echo "==============================="
# KUBECONFIG_CMD=$(terraform output -raw to_configure_kubectl)
# echo "Executing: $KUBECONFIG_CMD"
# eval "$KUBECONFIG_CMD"

# echo "Verifying EKS cluster connectivity..."
# if kubectl get nodes > /dev/null 2>&1; then
#     echo "✅ Successfully connected to EKS cluster!"
#     kubectl get nodes
# else
#     echo "❌ Failed to connect to EKS cluster."
#     exit 1
# fi

# ---------------------------------------------------------------
# STEP 4: Create AWS Data Plane (Redis, RDS, SQS, etc.)
# ---------------------------------------------------------------
echo
echo "==============================="
echo "STEP 4: Create AWS Data Plane using Terraform"
echo "==============================="
cd "$SCRIPT_DIR/02_microservice_dataplane/01_AWS_Data_Plane_terraform-manifests"
terraform init
terraform apply -auto-approve
echo "✅ AWS Data Plane created successfully!"

# ---------------------------------------------------------------
# Done
# ---------------------------------------------------------------
echo
echo "============================================================"
echo "  ✅ All infrastructure created successfully!"
echo "============================================================"
echo "  - VPC"
echo "  - EKS Cluster + Addons (LBC, EBS CSI, ExternalDNS, etc.)"
# echo "  - Kubeconfig configured"
echo "  - AWS Data Plane (Redis, RDS, SQS, etc.)"
echo "============================================================"
