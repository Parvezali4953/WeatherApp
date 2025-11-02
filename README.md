# Cloud-Native DevOps Pipeline for AWS

This project demonstrates a complete, end-to-end **Continuous Integration and Continuous Deployment (CI/CD)** pipeline for a containerized Python Flask application deployed to **AWS ECS Fargate**.

The entire cloud infrastructure is defined and managed using **Terraform** in a modular, reusable structure. The deployment process is fully automated using **GitHub Actions**, ensuring that every change pushed to the `main` branch is automatically built, tested, and deployed to production with zero downtime.

## 🚀 Key Technologies & Cloud Services

| Category                  | Tools & Services                                                    | Description                                                                                                                              |
| :------------------------ | :------------------------------------------------------------------ | :--------------------------------------------------------------------------------------------------------------------------------------- |
| **Infrastructure as Code**  | **Terraform**                                                       | Provisions the entire AWS environment, including the VPC, Subnets, ALB, ECR, CloudWatch Logs, IAM Roles, and the ECS Fargate Cluster/Service. |
| **Cloud Platform**          | **AWS** (ECS Fargate, ALB, ECR, VPC, S3, Secrets Manager, CloudWatch) | Utilizes serverless container orchestration (Fargate) for a scalable, cost-effective, and low-maintenance application runtime environment.       |
| **CI/CD Automation**      | **GitHub Actions**                                                  | Automates testing, Docker image building, pushing to ECR, and deploying new versions to ECS on every push to the `main` branch.              |
| **Containerization**        | **Docker**                                                          | Containerizes the Python/Flask web application using a multi-stage `Dockerfile` for a small and secure production image.                   |
| **State & Secrets Management**| **AWS S3, DynamoDB, Secrets Manager**                             | Manages Terraform state remotely and securely using an S3 backend with DynamoDB for state locking. Application secrets are stored in Secrets Manager. |

## 🏛️ Architecture Diagram

*(Optional but highly recommended: Include a simple diagram showing the flow from a user to the ALB to the ECS tasks in the private subnet.)*

## 📂 Repository Structure

The repository is organized into logical, self-contained units, following industry best practices.

| Directory / File          | Description                                                                                                                                      |
| :------------------------ | :----------------------------------------------------------------------------------------------------------------------------------------------- |
| **`/app`**                  | Contains the Python Flask application source code, the `Dockerfile` for containerization, and the `pytest` test suite.                             |
| **`/infra`**                | The **root Terraform directory**. It contains the orchestration logic (`main.tf`) that assembles the infrastructure by calling all child modules. |
| `/infra/[module_name]`    | Individual child modules for each component of the infrastructure (e.g., `networking`, `ecs`, `alb`). Each module is self-contained and reusable. |
| **`/state`**                | A separate Terraform configuration to bootstrap the remote state backend (the S3 bucket and DynamoDB table). This is run once during initial setup. |
| **`/.github/workflows`**  | Contains the YAML files for the GitHub Actions pipelines: `ci.yml` (for testing) and `deploy.yml` (for deployment).                                |

## ⚙️ Execution and Deployment Workflow

This project follows a professional two-phase deployment process: a one-time infrastructure bootstrap, followed by fully automated application deployments.

### Phase 1: Infrastructure Bootstrap (Run Once Manually)

These steps create the foundational AWS resources for the project.

**Prerequisites:**
1. An **AWS Account** with an IAM user configured with administrative permissions.
2. **AWS CLI** installed and configured locally (`aws configure`).
3. **Terraform** installed locally.

#### Step 1.1: Deploy the Terraform State Backend

First, we create the S3 bucket and DynamoDB table that Terraform will use to store its state.

```
# Navigate to the state directory
cd state

# Initialize Terraform (for this directory)
terraform init

# Review and apply the plan to create the backend resources
terraform plan
terraform apply --auto-approve
```

#### Step 1.2: Deploy the Main Application Infrastructure

Next, we deploy the entire application stack using the remote backend we just created.

```
# Navigate to the main infrastructure directory
cd ../infra

# Initialize Terraform. It will automatically detect and connect to the S3 backend.
terraform init

# Plan and apply the infrastructure.
# You must provide the sensitive weather_api_key and a placeholder container_image.
terraform plan -var="weather_api_key=YOUR_SECRET_KEY_HERE" -var="container_image=nginx:latest"
terraform apply -var="weather_api_key=YOUR_SECRET_KEY_HERE" -var="container_image=nginx:latest" --auto-approve
```
**Result:** At this point, the entire cloud infrastructure is live, and the application is running with a placeholder Nginx container. The public URL of the application will be shown in the Terraform outputs.

### Phase 2: Automated Application Deployment (CI/CD)

From this point forward, every deployment is handled automatically by GitHub Actions.

**Prerequisites:**
1. The infrastructure from Phase 1 has been successfully deployed.
2. The following secrets have been added to your GitHub repository's secrets (`Settings > Secrets and variables > Actions`):
   * `AWS_ACCESS_KEY_ID`: The access key for your IAM user.
   * `AWS_SECRET_ACCESS_KEY`: The secret key for your IAM user.

#### The CI/CD Pipeline in Action:

1.  **Code Change:** A developer makes a change to the application code inside the `/app` directory and pushes it to a feature branch.
2.  **Continuous Integration (CI):** The push triggers the `ci.yml` workflow, which automatically runs the `pytest` suite to ensure the changes have not introduced any bugs.
3.  **Merge to Main:** After the pull request is approved and merged, the code is pushed to the `main` branch.
4.  **Continuous Deployment (CD):** This push triggers the `deploy.yml` workflow, which performs the following steps:
    *   Builds a new Docker image from the application code.
    *   Tags the image with the unique Git commit SHA.
    *   Pushes the new image to the ECR repository created by Terraform.
    *   Updates the ECS task definition with the new image tag.
    *   Triggers a **zero-downtime rolling deployment** of the ECS service.

**Result:** Within minutes, the new version of the application is live and serving traffic, all without any manual intervention.
```
