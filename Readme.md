## High level Diagram 
This diagram illustrates the flow of code from development to a live deployment in the Kubernetes cluster and the final state of the AWS infrastructure that is provisioned by your Terraform code.

<img width="546" height="856" alt="image" src="https://github.com/user-attachments/assets/9eb17311-de53-41d0-969f-82ae630183a6" />

## Part I: Kubernetes Deployment and Operations

This section details the process for containerizing, deploying, and managing the application on a Kubernetes cluster.

### Local Cluster Provisioning with `kind`
For local development and testing, a multi-node Kubernetes cluster is provisioned using `kind`. The process is automated by the `setup-cluster.sh` script, which ensures the correct configuration, including necessary port mappings for the Ingress controller, is applied.

### Application Deployment Architecture
The application is deployed to the cluster using a set of declarative Kubernetes manifests that define the desired state of the system:

* **Deployment (`deployment.yaml`)**: Manages the application's lifecycle, defining the container image, replica count, resource requests and limits, and liveness/readiness probes for health monitoring.
* **Service (`service.yaml`)**: Provides a stable internal network endpoint (`ClusterIP`) to route traffic to the application pods.
* **Ingress (`ingress.yaml`)**: Manages external access to the application, using the NGINX Ingress Controller to route HTTP traffic from outside the cluster to the internal service.

### Monitoring and Observability
A comprehensive monitoring solution is implemented using the `kube-prometheus-stack`, providing deep insights into both cluster and application health.

* **Application Instrumentation**: The Node.js application is instrumented with the `prom-client` library to expose custom Prometheus metrics (e.g., HTTP request latency, error rates) via a standard `/metrics` endpoint.
* **Metric Collection**: A `ServiceMonitor` custom resource is configured to enable Prometheus to automatically discover and scrape metrics from the application's service.
* **Visualization**: A custom Grafana dashboard provides a centralized view of key performance indicators (KPIs), including application request rates, latency distributions, and node-level resource utilization (CPU & Memory).

### CI/CD Pipeline with GitHub Actions
The entire build, test, and deployment lifecycle is automated through a robust CI/CD pipeline powered by GitHub Actions.

* **Secure Authentication**: The pipeline leverages **OIDC Connect** to establish a secure, short-lived trust relationship with AWS IAM. This modern approach eliminates the need to store long-lived static credentials (like AWS keys) as GitHub secrets.
* **Automated Workflow**: The pipeline is triggered on every push to the `main` branch and executes the following sequence:
    1.  **Build & Push**: The application is built into a Docker image and pushed to a container registry.
    2.  **Vulnerability Scanning**: The image is scanned for security vulnerabilities using **Trivy**. The build will fail if any `HIGH` or `CRITICAL` severity vulnerabilities are detected, preventing insecure code from being deployed.
    3.  **Deploy to EKS**: The pipeline securely authenticates with AWS, connects to the EKS cluster, and triggers a rolling update by setting the new image tag on the Kubernetes Deployment.
    4.  **Automated Rollback**: If the new deployment fails its health checks, the pipeline automatically triggers a rollback to the last known stable version.

### Implemented Security Best Practices
Security is integrated throughout the deployment process using a defense-in-depth strategy:

* **Least-Privilege RBAC**: Kubernetes Roles and RoleBindings are configured to ensure the application's service account has the minimum permissions necessary for its operation.
* **Network Policies**: A network firewall is enforced at the pod level, restricting ingress traffic to only allow connections from the NGINX Ingress controller, thereby isolating the application.
* **Secrets Management**: Sensitive configuration data is managed using native Kubernetes Secrets.
* **Continuous Vulnerability Scanning**: Automated security scanning is a required step in the CI/CD pipeline.

---

## Part II: Infrastructure as Code with Terraform

The underlying AWS cloud infrastructure is provisioned and managed declaratively using Terraform, ensuring a reproducible, version-controlled environment.

### Infrastructure Overview
* **Remote State Management**: Terraform's state is stored securely in a version-enabled and encrypted **S3 bucket**. A **DynamoDB table** is used for state locking to prevent concurrent modifications and ensure state integrity.
* **Modular Design**: The infrastructure code is organized into reusable modules for clarity and scalability:
    * **`vpc-network`**: Provisions the core networking components, including the VPC, public/private subnets, Internet Gateway, NAT Gateway, and associated route tables.
    * **`servers`**: Provisions the compute layer, including EC2 instances, security groups, and the bastion host access pattern.

### Deployment Workflow

#### 1. Prerequisites
* Terraform CLI (v1.0.0+)
* AWS CLI (v2.0.0+), configured with appropriate credentials.

#### 2. Backend Configuration
The S3 bucket and DynamoDB table for the remote backend must be created in AWS prior to initialization. The names must be updated in the `backend.tf` file.

#### 3. Provisioning the Infrastructure
The following commands are used to deploy and manage the infrastructure:

```bash
# Initialize the Terraform workspace and configure the backend
terraform init

# Preview the changes that will be applied
terraform plan

# Apply the configuration to create the resources
terraform apply


#Secure Instance Access
#Access to the private EC2 instances is restricted and must be routed through the bastion host.

#Connect to the Bastion Host:
ssh -i /path/to/key.pem ec2-user@<BASTION_PUBLIC_IP>

# Connect to a Private Instance: Use SSH agent forwarding to securely connect from the bastion to the private instance without exposing private keys.

# On your local machine, add your key to the agent
ssh-add /path/to/key.pem

# Connect to the bastion with agent forwarding enabled
ssh -A ec2-user@<BASTION_PUBLIC_IP>

# From the bastion, connect to the private instance
ssh ec2-user@<PRIVATE_INSTANCE_IP>

# Resource Cleanup
# To de-provision all infrastructure and prevent ongoing charges, run the destroy command.

terraform destroy

