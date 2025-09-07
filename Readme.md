Part I: Kubernetes Setup & Operations

Local Cluster Provisioning (kind)
For local development and testing, a 3-node Kubernetes cluster can be provisioned using kind. The setup-cluster.sh script automates this process, ensuring the necessary port mappings for the Ingress controller are configured.

Application Deployment & Ingress
The application is deployed to the cluster using a set of Kubernetes manifests:

deployment.yaml: Defines the desired state for the application pods, including resource requests/limits and health probes.

service.yaml: Creates a stable ClusterIP service to expose the application pods internally.

ingress.yaml: Uses the NGINX Ingress Controller to manage external access and route traffic to the service.

Monitoring & Observability 📈
The cluster and application are monitored using the kube-prometheus-stack.

Instrumentation: The Node.js app is instrumented with prom-client to expose custom metrics (e.g., request latency and rate) via a /metrics endpoint.

Scraping: A ServiceMonitor CRD is configured to tell Prometheus how to discover and scrape metrics from the application's service.

Dashboard: A custom Grafana dashboard was created to visualize key metrics for both the application and the Kubernetes nodes.

CI/CD Pipeline with GitHub Actions 🤖
A CI/CD pipeline automates the build, scan, push, and deploy process.

Trigger: The workflow runs on every push to the main branch.

Secure Authentication: Uses OIDC Connect to establish a trust relationship between GitHub Actions and AWS IAM. This eliminates the need for long-lived AWS secrets in GitHub.

Workflow:

Build & Push: Builds the Docker image and pushes it to Docker Hub.

Vulnerability Scan: Integrates Trivy to scan the image for HIGH or CRITICAL vulnerabilities, failing the build if any are found.

Deploy: Authenticates with AWS, connects to the EKS cluster, and updates the Kubernetes deployment with the new image tag using kubectl set image.

Rollback: Includes logic to automatically roll back the deployment if the rollout fails.

Security Best Practices 🛡️
Several security best practices are implemented:

RBAC: Least-privilege Roles and RoleBindings are defined.

Network Policies: Limits pod-to-pod traffic, allowing ingress only from the NGINX controller.

Secrets Management: Uses Kubernetes Secrets for sensitive data.

Vulnerability Scanning: Integrated directly into the CI/CD pipeline.

🏗️ Part II: Terraform for AWS Infrastructure
The entire underlying AWS infrastructure is managed as code using Terraform for automation and consistency.

2.1 Infrastructure Overview
Remote State: Terraform state is stored securely in an S3 bucket with versioning and encryption. A DynamoDB table is used for state locking to prevent conflicts.

Modular Design: The code is organized into reusable modules:

vpc-network: Provisions the VPC, subnets, IGW, NAT Gateway, and route tables.

servers: Provisions EC2 instances, security groups, and sets up the bastion host configuration.

2.2 Prerequisites & Setup
Tools: Terraform CLI and AWS CLI must be installed and configured.

Backend Setup: An S3 bucket and DynamoDB table must be created manually first, and their names updated in backend.tf.

Deployment Commands:

Bash

# Initialize Terraform and configure the backend
terraform init

# Preview the changes
terraform plan 

# Apply the changes to create the infrastructure
terraform apply 

2.3 Accessing EC2 Instances
Access to the private instance is secured through the bastion host.

SSH to Bastion: ssh -i /path/to/key.pem ec2-user@<BASTION_PUBLIC_IP>

SSH to Private Instance: Use SSH agent forwarding (ssh -A) to connect to the bastion, then from the bastion, ssh ec2-user@<PRIVATE_INSTANCE_IP>.

2.4 Cleanup
To destroy all infrastructure and avoid AWS charges, run:

Bash

terraform destroy