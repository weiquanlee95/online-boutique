#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================================"
echo "  Online Boutique - Full Infrastructure Setup"
echo "============================================================"
echo

# ---------------------------------------------------------------
# STEP 1: Create VPC + EKS + Karpenter + NodePools
# ---------------------------------------------------------------
echo "==============================="
echo "STEP 1: Create Cluster Environment"
echo "==============================="
cd "$SCRIPT_DIR/01_EKS_cluster_environment"
./create-cluster-with-karpenter.sh
echo "✅ Cluster environment created successfully!"

# ---------------------------------------------------------------
# STEP 2: Create AWS Data Plane (Redis, RDS, SQS, etc.)
# ---------------------------------------------------------------
echo
echo "==============================="
echo "STEP 2: Create AWS Data Plane using Terraform"
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
echo "  - EKS Cluster + Addons"
echo "  - Karpenter Terraform + NodePools"
echo "  - Kubeconfig configured"
echo "  - AWS Data Plane (Redis, RDS, SQS, etc.)"
echo
echo "Note: the standalone Metrics Server Terraform stack is not called here."
echo "It overlaps with the metrics-server addon already declared in the EKS add-ons layer."
echo "============================================================"
