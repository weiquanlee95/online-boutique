# online-boutique

## Course Sequence Commands

This README is arranged in the same order you would typically follow in the course flow: AWS setup, EKS discovery, kubectl access, cluster verification, add-on checks, Karpenter checks, Spot workflow, then troubleshooting and cleanup.

### 1. Set common environment variables

`export AWS_REGION="ap-southeast-1"`
Sets the AWS region used by later AWS CLI commands.

`export EKS_CLUSTER_NAME="online-boutique-dev-eks-cluster-dev"`
Sets the EKS cluster name used by later EKS and kubectl setup commands.

`export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)`
Reads the current AWS account ID and stores it for later reference.

`echo $AWS_REGION`
Prints the configured AWS region.

`echo $EKS_CLUSTER_NAME`
Prints the configured EKS cluster name.

`echo $AWS_ACCOUNT_ID`
Prints the configured AWS account ID.

### 2. Check AWS identity and region

`aws sts get-caller-identity`
Shows the currently authenticated AWS account, user, or role.

`aws configure list`
Shows which AWS profile, access key source, and region the CLI is using.

### 3. Discover the EKS cluster

`aws eks list-clusters --region $AWS_REGION --output table`
Lists available EKS clusters in the selected region in a readable table.

`aws eks list-clusters --region $AWS_REGION --query 'clusters[0]' --output text`
Returns the first cluster name in the region as plain text.

### 4. Update kubeconfig and verify cluster access

`aws eks update-kubeconfig --region $AWS_REGION --name $EKS_CLUSTER_NAME`
Adds the target EKS cluster to your local kubeconfig and switches kubectl access to it.

`aws eks update-kubeconfig --region ap-southeast-1 --name online-boutique-dev-eks-cluster-dev`
Runs the same kubeconfig update using the current repo's concrete region and cluster name values.

`kubectl config current-context`
Shows the kubectl context currently in use.

`kubectl cluster-info`
Shows the Kubernetes API endpoint and core cluster service endpoints.

`kubectl get nodes`
Lists the nodes currently registered to the cluster.

`kubectl get nodes -o wide`
Lists nodes with additional details such as internal IP and OS image.

### 5. Login to AWS ECR

`aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin 927749346049.dkr.ecr.ap-southeast-1.amazonaws.com`
Authenticates Docker to your private ECR registry so images can be pulled or pushed.

### 6. Review EKS cluster status and details

`aws eks list-clusters --region $AWS_REGION`
Lists all EKS clusters in the selected region.

`aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION`
Shows the full EKS cluster configuration and status.

`aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION --query 'cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint,VpcId:resourcesVpcConfig.vpcId}'`
Shows a compact summary of the cluster name, status, version, API endpoint, and VPC ID.

`aws eks list-addons --cluster-name $EKS_CLUSTER_NAME --region $AWS_REGION`
Lists the EKS-managed add-ons installed on the cluster.

`aws eks list-pod-identity-associations --cluster-name $EKS_CLUSTER_NAME --region $AWS_REGION`
Lists EKS Pod Identity associations configured for the cluster.

### 7. Review Terraform state and outputs

`cd 01_EKS_cluster_environment/01_VPC_terraform-manifests`
Moves to the VPC Terraform layer.

`terraform init`
Initializes the Terraform working directory and providers.

`terraform validate`
Validates Terraform configuration syntax and structure.

`terraform plan`
Shows the infrastructure changes Terraform would make.

`terraform output`
Prints output values from the current Terraform state.

`cd ../02_EKS_terraform-manifests_with_addons`
Moves to the EKS and add-ons Terraform layer.

`terraform init`
Initializes the EKS Terraform working directory.

`terraform validate`
Validates the EKS Terraform configuration.

`terraform plan`
Shows proposed EKS and add-on changes.

`terraform output`
Prints EKS-related output values.

`cd ../03_KARPENTER_terraform-manifests`
Moves to the Karpenter Terraform layer.

`terraform init`
Initializes the Karpenter Terraform working directory.

`terraform validate`
Validates the Karpenter Terraform configuration.

`terraform plan`
Shows proposed Karpenter infrastructure changes.

`terraform output`
Prints Karpenter-related output values.

### 8. Review VPC and networking information

`VPC_ID=$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION --query 'cluster.resourcesVpcConfig.vpcId' --output text)`
Reads the VPC ID used by the current EKS cluster into a shell variable.

`echo $VPC_ID`
Prints the resolved VPC ID.

`aws ec2 describe-vpcs --vpc-ids $VPC_ID --region $AWS_REGION`
Shows details of the VPC used by the cluster.

`aws ec2 describe-subnets --filters Name=vpc-id,Values=$VPC_ID --region $AWS_REGION`
Lists the subnets associated with the cluster VPC.

`aws ec2 describe-route-tables --filters Name=vpc-id,Values=$VPC_ID --region $AWS_REGION`
Lists route tables associated with the VPC.

`aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPC_ID --region $AWS_REGION`
Lists security groups associated with the VPC.

`aws ec2 describe-nat-gateways --filter Name=vpc-id,Values=$VPC_ID --region $AWS_REGION`
Lists NAT gateways deployed in the VPC.

`aws elbv2 describe-load-balancers --region $AWS_REGION`
Lists ALBs and NLBs in the current region.

### 9. Run core Kubernetes status checks

`kubectl get pods -A`
Lists all pods in all namespaces.

`kubectl get pods -A -o wide`
Lists all pods with node placement and IP details.

`kubectl get svc -A`
Lists all services in all namespaces.

`kubectl get ingress -A`
Lists all ingress resources in all namespaces.

`kubectl get sa -A`
Lists all service accounts in all namespaces.

`kubectl get cm -A`
Lists all ConfigMaps in all namespaces.

`kubectl get events -A --sort-by=.lastTimestamp`
Lists recent cluster events in chronological order.

### 10. Watch cluster components in real time

`kubectl get pods -n kube-system -w`
Watches system namespace pods as they change.

`kubectl get svc -A -w`
Watches services across the cluster as they change.

`kubectl get ingress -A -w`
Watches ingress resources across the cluster as they change.

### 11. Inspect workloads and scheduling

`kubectl get deploy -A`
Lists deployments across all namespaces.

`kubectl describe deployment <deployment-name> -n <namespace>`
Shows detailed deployment configuration, events, and rollout state.

`kubectl describe pod <pod-name> -n <namespace>`
Shows detailed pod configuration, status, and events.

`kubectl get pods -o wide`
Shows pod placement and node assignment.

`kubectl top nodes`
Shows current node CPU and memory usage.

`kubectl top pods -A`
Shows current pod CPU and memory usage across namespaces.

### 12. Logs and rollout checks

`kubectl logs -f -l app.kubernetes.io/name=<app-name> -n <namespace> --tail=200`
Streams the most recent logs for pods matching the application label.

`kubectl rollout status deployment/<deployment-name> -n <namespace>`
Shows whether a deployment rollout has completed successfully.

`kubectl rollout history deployment/<deployment-name> -n <namespace>`
Shows the rollout revision history of a deployment.

### 13. Helm status checks

`helm list -A`
Lists Helm releases across all namespaces.

`helm list -n kube-system`
Lists Helm releases in the kube-system namespace.

`helm status karpenter -n kube-system`
Shows the status of the Karpenter Helm release.

### 14. Check EKS add-ons and common controllers

`kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller`
Shows AWS Load Balancer Controller pods.

`kubectl get deployment -n kube-system aws-load-balancer-controller`
Shows the deployment state of AWS Load Balancer Controller.

`kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller --tail=100`
Shows recent logs for AWS Load Balancer Controller.

`kubectl get pods -n kube-system | grep ebs-csi`
Shows EBS CSI pods running in kube-system.

`kubectl get ds -n kube-system | grep ebs-csi`
Shows EBS CSI daemonsets.

`kubectl get deploy -n kube-system | grep ebs-csi`
Shows EBS CSI deployments.

### 15. Check Karpenter installation and resources

`kubectl get pods -n kube-system -l app.kubernetes.io/name=karpenter`
Shows Karpenter controller pods.

`helm get values karpenter -n kube-system | grep interruptionQueue`
Checks which SQS interruption queue Karpenter is configured to use.

Expected example: `interruptionQueue: online-boutique-dev-eks-cluster-dev`
Shows the expected interruption queue name for this environment.

`aws sqs list-queues | grep -i online-boutique-dev-eks-cluster-dev`
Checks that the interruption queue exists in SQS.

`aws sqs get-queue-url --queue-name online-boutique-dev-eks-cluster-dev --region $AWS_REGION`
Returns the full URL of the interruption queue.

`kubectl get ec2nodeclass`
Lists EC2NodeClass resources managed by Karpenter.

`kubectl describe ec2nodeclass default-ec2nodeclass`
Shows full details of the default EC2NodeClass.

`kubectl get nodepools`
Lists Karpenter NodePools.

`kubectl describe nodepool spot-nodepool`
Shows the full configuration and status of the Spot NodePool.

`kubectl get nodepool spot-nodepool -o yaml`
Prints the full Spot NodePool YAML.

`kubectl get nodepool spot-nodepool -o yaml | grep -A20 -B5 'karpenter.sh/capacity-type'`
Extracts the section of the NodePool YAML that shows the capacity type setting.

`kubectl get nodeclaims -o wide`
Lists NodeClaims with expanded details.

`kubectl describe nodeclaim <nodeclaim-name>`
Shows detailed information for a specific NodeClaim.

`kubectl logs -n kube-system -l app.kubernetes.io/name=karpenter -f`
Streams Karpenter controller logs in real time.

`kubectl get deployment -n kube-system karpenter -o jsonpath='{.spec.template.spec.containers[0].image}'`
Prints the Karpenter controller image version in use.

### 16. Review node and EC2 instance information

`kubectl get nodes -o custom-columns=NAME:.metadata.name,PROVIDER-ID:.spec.providerID`
Maps Kubernetes node names to their cloud provider IDs.

`aws ec2 describe-instances --filters Name=tag:aws:eks:cluster-name,Values=$EKS_CLUSTER_NAME --region $AWS_REGION`
Lists EC2 instances tagged as part of the EKS cluster.

`aws ec2 describe-instances --filters 'Name=instance-lifecycle,Values=spot' --region $AWS_REGION`
Lists Spot EC2 instances in the current region.

### 17. Check application access and service exposure

`kubectl get ingress`
Shows ingress resources and any exposed load balancer addresses.

`kubectl get svc`
Shows services and their cluster or external endpoints.

`kubectl port-forward pod/<pod-name> 8080:80 -n <namespace>`
Forwards a pod port locally so the application can be accessed from your machine.

### 18. Run the Spot test workflow

`kubectl apply -f kube-manifests-Spot/Spot_autoscaling_test.yaml`
Deploys the upstream Spot autoscaling test manifest.

Expected example: `deployment.apps/karpenter-autoscale-demo-spot created`
Shows the expected deployment creation message.

`kubectl get pods`
Checks the initial status of the test pods.

`kubectl get pods -o wide`
Shows where the test pods are scheduled.

`kubectl get nodeclaims -w`
Watches NodeClaims being created while Karpenter provisions capacity.

Expected example: `spot-nodepool-abc123 ... spot ...` and `spot-nodepool-xyz789 ... spot ...`
Shows the expected sign that Karpenter is creating Spot-backed NodeClaims.

`kubectl get nodes`
Checks when the new nodes appear in the cluster.

`kubectl get nodes --selector=karpenter.sh/capacity-type=spot`
Filters nodes to only the Spot-backed nodes.

`kubectl get nodes -L karpenter.sh/capacity-type,node.kubernetes.io/instance-type,topology.kubernetes.io/zone`
Shows node labels for capacity type, instance type, and availability zone.

`kubectl get node <spot-node-name> -o json | jq '.metadata.labels'`
Prints all labels on a specific Spot node.

`kubectl get nodes -l karpenter.sh/capacity-type=spot -o custom-columns=NAME:.metadata.name,INSTANCE-TYPE:.metadata.labels."node\\.kubernetes\\.io/instance-type"`
Shows instance type diversity across Spot nodes.

`kubectl get nodes -l karpenter.sh/capacity-type=spot -o custom-columns=NAME:.metadata.name,INSTANCE-ID:.spec.providerID`
Shows the provider IDs for Spot nodes so they can be matched to EC2 instances.

`kubectl get pods -o wide | grep karpenter-autoscale-demo-spot`
Shows the nodes used by the test deployment pods.

`kubectl get pods -o wide | grep karpenter-autoscale-demo-spot | awk '{print $7}' | sort | uniq -c`
Counts how many test pods landed on each node.

### 19. Spot test cleanup sequence

`kubectl delete -f kube-manifests-Spot/Spot_autoscaling_test.yaml`
Deletes the Spot test deployment.

`kubectl get pods`
Checks pod termination progress after deletion.

`kubectl get nodes`
Checks when nodes begin draining or disappearing.

`kubectl get nodeclaims`
Checks when NodeClaims are removed after cleanup.

### 20. Troubleshooting commands

`kubectl logs -n kube-system -l app.kubernetes.io/name=karpenter --tail=50`
Shows recent Karpenter logs for troubleshooting provisioning issues.

`kubectl get nodepool spot-nodepool`
Checks whether the Spot NodePool exists and is ready.

`kubectl get deploy karpenter-autoscale-demo-spot -o yaml | grep -A2 nodeSelector`
Checks whether the test deployment is selecting the expected capacity type.

### 21. Full cleanup commands

`kubectl delete nodepools --all`
Deletes all Karpenter NodePools.

`kubectl wait --for=delete nodeclaims --all --timeout=300s`
Waits for all Karpenter NodeClaims to be removed.

`kubectl get nodes -l karpenter.sh/nodepool`
Checks whether any Karpenter-managed nodes remain.

`./destroy-all-infra.sh`
Destroys the full environment using the project cleanup script.

## Upstream Example Note

`cd 17_03_Karpenter_Spot_Instances`
Moves to the upstream course folder in the StackSimplify repository.

The upstream guide uses `kube-manifests-Spot/Spot_autoscaling_test.yaml`, but that file is not present in this repo.

## Notes

- The interruption queue in this repo is configured from the EKS cluster name.
- Your workload manifests now target `karpenter.sh/capacity-type: spot`, which matches the Karpenter Spot NodePool setting.
