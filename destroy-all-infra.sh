#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================================"
echo "  Online Boutique - Full Infrastructure Destroy"
echo "============================================================"
echo

# ---------------------------------------------------------------
# STEP 1: Delete Kubernetes Manifests
# ---------------------------------------------------------------
echo "==============================="
echo "STEP 1: Delete Kubernetes Manifests"
echo "==============================="
if kubectl cluster-info > /dev/null 2>&1; then
    cd "$SCRIPT_DIR/03_microservice_manifests"
    kubectl delete -k . --ignore-not-found
    echo "✅ Kubernetes manifests deleted!"
else
    echo "⚠️  Cannot connect to cluster, skipping manifest cleanup"
fi

# ---------------------------------------------------------------
# STEP 2: Destroy AWS Data Plane (Redis, RDS, SQS, etc.)
# ---------------------------------------------------------------
echo
echo "==============================="
echo "STEP 2: Destroy AWS Data Plane using Terraform"
echo "==============================="
cd "$SCRIPT_DIR/02_microservice_dataplane/01_AWS_Data_Plane_terraform-manifests"
terraform init
terraform destroy -auto-approve
echo "✅ AWS Data Plane destroyed!"

# ---------------------------------------------------------------
# STEP 3: Destroy EKS Cluster
# ---------------------------------------------------------------
echo
echo "==============================="
echo "STEP 3: Destroy EKS Cluster using Terraform"
echo "==============================="
cd "$SCRIPT_DIR/01_EKS_cluster_environment/02_EKS_terraform-manifests_with_addons"
terraform init
terraform destroy -auto-approve
echo "✅ EKS Cluster destroyed!"

# ---------------------------------------------------------------
# STEP 4: Clean up orphaned EKS security groups in VPC
# ---------------------------------------------------------------
echo
echo "==============================="
echo "STEP 4: Clean up orphaned EKS security groups"
echo "==============================="
cd "$SCRIPT_DIR/01_EKS_cluster_environment/01_VPC_terraform-manifests"
terraform init -input=false > /dev/null 2>&1
VPC_ID=$(terraform output -raw vpc_id 2>/dev/null || echo "")

if [ -n "$VPC_ID" ]; then
    echo "VPC ID: $VPC_ID"
    # Find and delete any non-default security groups left behind by EKS
    SG_IDS=$(aws ec2 describe-security-groups \
        --filters "Name=vpc-id,Values=$VPC_ID" \
        --query 'SecurityGroups[?GroupName!=`default`].GroupId' \
        --output text --region ap-southeast-1 2>/dev/null || echo "")

    if [ -n "$SG_IDS" ] && [ "$SG_IDS" != "None" ]; then
        for SG_ID in $SG_IDS; do
            echo "Deleting orphaned security group: $SG_ID"
            aws ec2 delete-security-group --group-id "$SG_ID" --region ap-southeast-1 2>&1 || true
        done
        echo "✅ Orphaned security groups cleaned up!"
    else
        echo "✅ No orphaned security groups found"
    fi
else
    echo "⚠️  Could not determine VPC ID, skipping SG cleanup"
fi

# ---------------------------------------------------------------
# STEP 5: Destroy VPC
# ---------------------------------------------------------------
echo
echo "==============================="
echo "STEP 5: Destroy VPC using Terraform"
echo "==============================="
cd "$SCRIPT_DIR/01_EKS_cluster_environment/01_VPC_terraform-manifests"
terraform init
terraform destroy -auto-approve
echo "✅ VPC destroyed!"

# ---------------------------------------------------------------
# Done
# ---------------------------------------------------------------
echo
echo "============================================================"
echo "  ✅ All infrastructure destroyed successfully!"
echo "============================================================"
echo "  - Kubernetes manifests deleted"
echo "  - AWS Data Plane (Redis, RDS, SQS, etc.) destroyed"
echo "  - EKS Cluster destroyed"
echo "  - VPC destroyed"
echo "============================================================"
