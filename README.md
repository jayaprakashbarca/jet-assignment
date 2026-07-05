Architecture overview:

<img width="800" height="600" alt="Architecture" src="https://github.com/user-attachments/assets/679ba557-2318-4cbc-b007-24b8cab25d8d" />



# Prerequisites

The following tools and platforms are used in this solution:

| Category                       | Technology               |
| ------------------------------ | ------------------------ |
| Cloud Infrastructure           | AWS                      |
| Infrastructure as Code         | Terraform                |
| Containerization               | Docker                   |
| Container Orchestration        | Kubernetes on Amazon EKS |
| Container Registry             | Amazon ECR               |
| Kubernetes Packaging           | Helm                     |
| GitOps / Continuous Deployment | Argo CD                  |
| Node Auto Scaling              | Karpenter                |
| API Validation                 | Postman                  |
| Application                    | Python Flask             |
| Database                       | MongoDB                  |
| Continuous Integration         | GitHub Actions           |

---

# Cluster Setup with Terraform

Terraform is used to provision the AWS infrastructure required for the EKS cluster.

The Terraform configuration creates resources such as:

1. VPC
2. Public and private subnets
3. Route tables
4. Internet Gateway and NAT Gateway
5. Amazon EKS cluster
6. Managed worker node groups
7. IAM roles and policies
8. Security groups
9. EKS add-ons
10. Karpenter IAM and discovery resources

## Step 1: Validate and Provision AWS Resources

Navigate to the Terraform directory:

```bash
cd terraform
```

Initialize Terraform:

```bash
terraform init
```

Format the Terraform configuration:

```bash
terraform fmt -recursive
```

Validate the configuration:

```bash
terraform validate
```

Create and review the execution plan:

```bash
terraform plan -out=tfplan
```

Provision the infrastructure:

```bash
terraform apply tfplan
```

---

## Step 2: Configure and Validate Kubernetes Access

Update the local kubeconfig to access the EKS cluster:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name <CLUSTER_NAME>
```

Verify the worker nodes:

```bash
kubectl get nodes
```

The cluster is ready when the nodes are in the `Ready` state.

---

# Application Deployment with Argo CD

Argo CD is used for GitOps-based application deployment.

It monitors the Git repository and synchronizes the required Helm-based Kubernetes resources to Amazon EKS.

## Step 1: Check Argo CD Applications

List all applications:

```bash
argocd app list
```

Check the MongoDB application:

```bash
argocd app get mongodb
```

Check the backend application:

```bash
argocd app get backend
```

---

## Step 2: Synchronize MongoDB and Backend

Synchronize MongoDB:

```bash
argocd app sync mongodb
```

Synchronize the backend application:

```bash
argocd app sync backend
```

Verify that the applications reach the expected state:

```text
Sync Status: Synced
Health Status: Healthy
```

---

# Accessing the API with Postman

The Flask API is exposed through a Kubernetes `LoadBalancer` service.

## Step 1: Get the API Endpoint

Run:

```bash
kubectl get svc -n articles
```

Example output:

```text
NAME                       TYPE           EXTERNAL-IP
articles-backend-service   LoadBalancer   abc123.us-east-1.elb.amazonaws.com
mongodb-headless           ClusterIP      <none>
```

Use the `EXTERNAL-IP` value of `articles-backend-service` as the API endpoint.

Example:

```text
http://abc123.us-east-1.elb.amazonaws.com
```

---

## Step 2: Create an Article

Open Postman and configure the request as follows.

**Method**

```text
POST
```

**URL**

```text
http://<LOAD-BALANCER-ENDPOINT>/articles
```

In Postman, select:

```text
Body → raw → JSON
```

**Request Body**

```json
{
  "title": "EKS Article",
  "content": "Testing Articles API using Postman",
  "author": "Jayaprakash"
}
```

The response returns the newly created article, including its `id`.

Save this `id` for the next API operations.

---

## Step 3: List All Articles

<img width="700" height="400" alt="Screenshot 2026-07-05 at 2 14 23 PM" src="https://github.com/user-attachments/assets/dadbd78c-9478-4f1e-a114-d2f950a76167" />

**Method**

```text
GET
```

**URL**

```text
http://<LOAD-BALANCER-ENDPOINT>/articles
```

This returns all available articles.

---

## Step 4: Get a Single Article

<img width="700" height="400" alt="Screenshot 2026-07-05 at 2 15 43 PM" src="https://github.com/user-attachments/assets/70befec8-ceb6-4204-b5da-48ffa6a7e010" />

Use the article ID returned from the create request.

**Method**

```text
GET
```

**URL**

```text
http://<LOAD-BALANCER-ENDPOINT>/articles/<ARTICLE_ID>
```

Example:

```text
http://abc123.us-east-1.elb.amazonaws.com/articles/686abc123
```

---

## Step 5: Update an Article

**Method**

```text
PUT
```

**URL**

```text
http://<LOAD-BALANCER-ENDPOINT>/articles/<ARTICLE_ID>
```

In Postman, select:

```text
Body → raw → JSON
```

**Request Body**

```json
{
  "title": "Updated Article",
  "content": "Updated using Postman",
  "author": "Jayaprakash"
}
```

---

## Step 6: Delete an Article

<img width="700" height="400" alt="Screenshot 2026-07-05 at 2 17 05 PM" src="https://github.com/user-attachments/assets/3a2f83f2-4674-49a9-bda4-738e44145db0" />


**Method**

```text
DELETE
```

**URL**

```text
http://<LOAD-BALANCER-ENDPOINT>/articles/<ARTICLE_ID>
```

This deletes the selected article.

---

# API Summary

| Method | Endpoint         | Description          |
| ------ | ---------------- | -------------------- |
| POST   | `/articles`      | Create an article    |
| GET    | `/articles`      | List all articles    |
| GET    | `/articles/<id>` | Get a single article |
| PUT    | `/articles/<id>` | Update an article    |
| DELETE | `/articles/<id>` | Delete an article    |

---

# Design Decisions

The following design decisions were made for this solution.

## 1. Terraform for Infrastructure as Code

Terraform is used to provision AWS resources such as:

* VPC
* Subnets
* EKS cluster
* IAM roles
* Security groups

This provides:

* Repeatable infrastructure provisioning
* Version-controlled infrastructure
* Consistent deployments
* Easier updates and cleanup

---

## 2. Amazon EKS for Kubernetes

Amazon EKS is used to run the containerized application workloads.

AWS manages the Kubernetes control plane, reducing the operational effort required to maintain the cluster.

Benefits include:

* Managed Kubernetes control plane
* AWS service integration
* Scalability
* High availability

---

## 3. GitHub Actions for Continuous Integration

GitHub Actions is used for the CI process.

The pipeline performs the following tasks:

1. Checks out the application source code
2. Builds the Docker image
3. Tags the Docker image
4. Authenticates with AWS
5. Pushes the image to Amazon ECR

This removes the need for manual Docker image builds and pushes.

---

## 4. Amazon ECR for Container Image Storage

Amazon ECR is used as the private container registry.

The GitHub Actions pipeline pushes the application image to ECR, and Amazon EKS pulls the image during application deployment.

```text
GitHub Actions
      |
      v
Build Docker Image
      |
      v
Amazon ECR
      |
      v
Amazon EKS
```

---

## 5. Helm for Kubernetes Application Packaging

Helm is used to package and manage Kubernetes resources.

Benefits include:

* Reusable templates
* Centralized configuration
* Easier application upgrades
* Easier rollback
* Reduced YAML duplication

---

## 6. Argo CD for GitOps Deployment

Argo CD is used for continuous deployment.

It monitors the Git repository and synchronizes the desired application state to Amazon EKS.

Benefits include:

* Git as the source of truth
* Automatic synchronization
* Drift detection
* Self-healing
* Controlled application deployment

Deployment flow:

```text
GitHub Repository
      |
      v
Argo CD
      |
      v
Helm Charts
      |
      v
Amazon EKS
```

---

## 7. MongoDB as a StatefulSet

MongoDB is deployed as a Kubernetes `StatefulSet`.

This design was selected because MongoDB requires:

* Stable pod identity
* Persistent storage
* Predictable pod naming
* Data retention across pod restarts

The database data is retained using persistent storage.

---

## 8. LoadBalancer Service for API Access

The Flask backend is exposed through a Kubernetes `LoadBalancer` service.

This provides an external AWS endpoint for:

* Postman testing
* External API access
* Assignment validation

Request flow:

```text
Postman
   |
   v
AWS LoadBalancer
   |
   v
Kubernetes Service
   |
   v
Flask API Pods
```

---

## 9. OPA Gatekeeper for Policy Enforcement

OPA Gatekeeper is used to enforce Kubernetes security and governance policies.

Example policies include:

* Blocking privileged containers
* Requiring CPU and memory limits
* Requiring mandatory labels
* Enforcing deployment standards

This provides Policy as Code and helps prevent non-compliant resources from being deployed.

---

## 10. Karpenter for Dynamic Node Scaling

Karpenter is used for dynamic worker node provisioning.

When pods cannot be scheduled because of insufficient cluster capacity, Karpenter provisions suitable EC2 capacity.

```text
Pending Pod
    |
    v
Karpenter
    |
    v
New EC2 Node
    |
    v
Pod Scheduled
```

Benefits include:

* Faster scaling
* Flexible EC2 instance selection
* Better resource utilization
* Improved cost efficiency

---

# CI/CD and GitOps Flow

The complete application delivery flow is:

```text
Developer
   |
   | git push
   v
GitHub Repository
   |
   v
GitHub Actions
   |
   | Build Docker Image
   | Tag Docker Image
   | Push Image
   v
Amazon ECR
   |
   v
Git Repository / Helm Configuration
   |
   v
Argo CD
   |
   | Synchronize
   v
Amazon EKS
   |
   +--> Flask API Pods
   |
   +--> MongoDB StatefulSet
   |
   +--> Persistent Storage
```

In summary:

* **Terraform** provisions the AWS infrastructure
* **GitHub Actions** handles CI and container image builds
* **Amazon ECR** stores Docker images
* **Helm** packages Kubernetes resources
* **Argo CD** handles GitOps deployment
* **Amazon EKS** runs the workloads
* **MongoDB** stores application data
* **OPA Gatekeeper** enforces policies
* **Karpenter** provides dynamic node scaling
* **Postman** is used to validate the API

Validation Screen-Shots:

1. DB & Backend deployed screenshot:

   <img width="700" height="500" alt="Screenshot 2026-07-05 at 2 03 24 PM" src="https://github.com/user-attachments/assets/89b01e22-eb39-4f8f-b90c-7cd48645328c" />

2. Security - OPA Deplyment

   <img width="1140" height="112" alt="Screenshot 2026-07-05 at 2 55 42 PM" src="https://github.com/user-attachments/assets/9ae40d38-1faa-4138-bb00-df8ab8430899" />


   <img width="1140" height="112" alt="Screenshot 2026-07-05 at 2 58 38 PM" src="https://github.com/user-attachments/assets/c2269406-3e67-4b4e-85fb-f93da3825660" />


3. ArgoCD deployment:

  <img width="782" height="178" alt="Screenshot 2026-07-05 at 3 48 56 PM" src="https://github.com/user-attachments/assets/5824ea15-bca8-4a8a-9316-dfe84f714e5f" />

   <img width="707" height="81" alt="Screenshot 2026-07-05 at 4 15 10 PM" src="https://github.com/user-attachments/assets/329d3588-620f-4c15-8635-518ded4108f9" />


4. ArgoCD -UI:

   <img width="1198" height="883" alt="Screenshot 2026-07-05 at 4 16 46 PM" src="https://github.com/user-attachments/assets/0d0e540d-585e-408b-b758-e7404b27c088" />

5. HPA deployment:

   <img width="960" height="81" alt="Screenshot 2026-07-05 at 7 08 09 PM" src="https://github.com/user-attachments/assets/dc95a916-502a-4cbd-a334-db6b7d69d444" />

6. Karpenter deployment:

   <img width="1134" height="132" alt="Screenshot 2026-07-05 at 9 14 35 PM" src="https://github.com/user-attachments/assets/cdda832f-524d-4b4a-aff2-ac03ebe7180e" />

7. Pod Disruption Budgets (PDB):

<img width="1026" height="161" alt="Screenshot 2026-07-05 at 11 38 47 PM" src="https://github.com/user-attachments/assets/156b6b5d-9ca1-414f-89d2-e17ce4963c54" />

<img width="725" height="101" alt="Screenshot 2026-07-05 at 11 39 45 PM" src="https://github.com/user-attachments/assets/88ec3f3a-c4a4-4890-a9b3-82d72c6b91c8" />

<img width="748" height="388" alt="Screenshot 2026-07-05 at 11 40 28 PM" src="https://github.com/user-attachments/assets/17fe1ad3-e7bd-4012-8b84-fcd3d7894914" />

8. StatefulSet:

   <img width="775" height="84" alt="Screenshot 2026-07-05 at 11 43 10 PM" src="https://github.com/user-attachments/assets/da63f1c4-8f04-4aa7-8217-6d5ba68ae3e3" />

9. Livesness& readuness probes:

    <img width="775" height="605" alt="Screenshot 2026-07-05 at 11 52 04 PM" src="https://github.com/user-attachments/assets/d233c5c3-d4ef-4990-8380-f389546df61f" />
