#!/bin/sh

set -eu

AWS_REGION="${AWS_REGION:-ap-southeast-1}"
CLUSTER_NAME="${EKS_CLUSTER_NAME:-online-boutique-dev-eks-cluster-dev}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_command kubectl
require_command aws
require_command cut
require_command date

kubectl get pods -n default -o wideS=$(kubectl get nodes -l karpenter.sh/capacity-type=spot -o jsonpath='{range .items[*]}{.spec.providerID}{"\n"}{end}' 2>/dev/null || true)

if [ -z "$PROVIDER_IDS" ]; then
  echo "No spot nodes found. Make sure at least one node exists with label karpenter.sh/capacity-type=spot." >&2
  exit 1
fi

QUEUE_URL=$(aws sqs get-queue-url \
  --queue-name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --query QueueUrl \
  --output text)

echo "Cluster name: $CLUSTER_NAME"
echo "Queue URL: $QUEUE_URL"

printf '%s\n' "$PROVIDER_IDS" | while IFS= read -r PROVIDER_ID; do
  [ -n "$PROVIDER_ID" ] || continue

  SPOT_INSTANCE_ID=$(printf '%s' "$PROVIDER_ID" | cut -d'/' -f5)

  if [ -z "$SPOT_INSTANCE_ID" ]; then
    echo "Unable to parse EC2 instance ID from provider ID: $PROVIDER_ID" >&2
    exit 1
  fi

  MESSAGE_BODY=$(cat <<EOF
{
  "version": "0",
  "id": "test-interrupt-$SPOT_INSTANCE_ID-$(date +%s)",
  "detail-type": "EC2 Spot Instance Interruption Warning",
  "source": "aws.ec2",
  "account": "$AWS_ACCOUNT_ID",
  "time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "region": "$AWS_REGION",
  "resources": [
    "arn:aws:ec2:$AWS_REGION:$AWS_ACCOUNT_ID:instance/$SPOT_INSTANCE_ID"
  ],
  "detail": {
    "instance-id": "$SPOT_INSTANCE_ID",
    "instance-action": "terminate"
  }
}
EOF
)

  echo "Sending interruption message for instance: $SPOT_INSTANCE_ID"

  aws sqs send-message \
    --queue-url "$QUEUE_URL" \
    --region "$AWS_REGION" \
    --message-body "$MESSAGE_BODY"
done

echo "Interruption messages sent for all current spot instances."
echo "Watch Karpenter logs and pod eviction events now."