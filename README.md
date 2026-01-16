# Cloud-Native DevOps Pipeline on AWS

This project demonstrates a complete, production-grade **Continuous Integration and Continuous Deployment (CI/CD)** pipeline that automatically builds, tests, and deploys a containerized Python Flask application to **AWS ECS Fargate**.

The entire cloud environment is defined as code using a modular and reusable **Terraform** structure. The workflow is fully automated with **GitHub Actions**, ensuring that any code pushed to the `main` branch is safely deployed to production with zero downtime.

## 🏛️ Architecture Diagram

A high-level overview of the infrastructure:

1.  A user sends a request to the Application Load Balancer (ALB).
2.  The ALB forwards the request to a healthy ECS task running in a private subnet.
3.  The ECS task runs the containerized Flask application, which fetches data from the internet via a NAT Gateway.
4.  All infrastructure is managed by Terraform, with its state stored securely in an S3 backend.
5.  A push to GitHub triggers the CI/CD pipeline, which deploys a new version.

## 🚀 Key Technologies & Services

| Category                     | Tools & Services                                                    | Purpose                                                                                                                             |
| :--------------------------- | :------------------------------------------------------------------ | :---------------------------------------------------------------------------------------------------------------------------------- |
| **Infrastructure as Code**     | **Terraform**                                                       | Provisions all AWS resources in a modular, reusable structure.                                                                      |
| **Cloud Platform**             | **AWS** (ECS Fargate, ALB, ECR, VPC, S3, Secrets Manager, CloudWatch) | Provides the serverless container orchestration, networking, and operational services needed to run the application securely.         |
| **CI/CD Automation**         | **GitHub Actions**                                                  | Automates testing, Docker image building, and deployment to ECS on every push to the `main` branch.                               |
| **Containerization**           | **Docker**                                                          | Containerizes the Flask application using a multi-stage `Dockerfile` for a lean and secure production image.                      |
| **State & Secrets Management** | **AWS S3, DynamoDB, Secrets Manager**                               | Manages Terraform state remotely with state locking. Manages the sensitive application API key securely.                          |

## 📂 Repository Structure

The repository follows a clean, modular structure that separates concerns.

| Path                       | Description                                                                                                                                     |
| :------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------- |
| **`/app`**                   | Contains the Python Flask application, `Dockerfile`, and the `pytest` test file.                                                                |
| **`/.github/workflows`**   | Contains the `ci.yml` (for testing) and `deploy.yml` (for deployment) GitHub Actions workflows.                                                     |
| **`/infra`**                 | The **root Terraform directory**. This is where you run `terraform` commands. It contains the `main.tf` file that orchestrates all the modules. |
| `/infra/[module_name]`     | Individual Terraform modules for each piece of infrastructure (e.g., `networking`, `ecs`, `iam`). Each module is self-contained and reusable.    |
| **`/state`**                 | A separate Terraform configuration to bootstrap the remote state backend (the S3 bucket and DynamoDB table). This is run **only once** during setup. |

## ⚙️ Execution & Deployment Workflow

This project uses a professional two-phase deployment process: a one-time manual infrastructure bootstrap, followed by fully automated application deployments via CI/CD.

### Phase 1: Infrastructure Bootstrap (Manual, One-Time Setup)

These steps create the foundational AWS resources for the project.

**Prerequisites:**
1.  An **AWS Account** with an IAM user configured with administrative permissions.
2.  **AWS CLI** installed and configured locally (`aws configure`).
3.  **Terraform** installed locally.

#### Step 1.1: Deploy the Terraform State Backend

First, we create the S3 bucket and DynamoDB table that Terraform will use to store its state file securely.

```
# Navigate to the state directory
cd state

# Initialize Terraform for this directory
terraform init

# Review and apply the plan to create the backend resources
terraform plan
terraform apply --auto-approve
```

#### Step 1.2: Deploy the Main Application Infrastructure

Next, we deploy the entire application stack. This step creates the VPC, IAM roles, ECS cluster, ALB, and all other resources.

```
# Navigate to the main infrastructure directory
cd ../infra

# Initialize Terraform. It will automatically connect to the S3 backend created above.
terraform init

# Plan and apply the infrastructure.
# You MUST provide your weather API key and a placeholder container image.
terraform apply -var="weather_api_key=YOUR_API_KEY_HERE" -var="container_image=nginx:latest" --auto-approve
```
**Result:** After this step, the entire cloud infrastructure is live. The public URL of the application will be shown in the Terraform outputs. At this point, visiting the URL will show the default Nginx welcome page.

### Phase 2: Automated Application Deployment (CI/CD)

From now on, every deployment is handled automatically by GitHub Actions.

**Prerequisites:**
1.  The infrastructure from Phase 1 has been successfully deployed.
2.  The following secrets have been added to your GitHub repository (`Settings > Secrets and variables > Actions`):
    *   `AWS_ACCESS_KEY_ID`: The access key for your IAM user.
    *   `AWS_SECRET_ACCESS_KEY`: The secret key for your IAM user.

#### The CI/CD Pipeline in Action:

1.  **Code Change:** A developer makes a change to the application code inside the `/app` directory.
2.  **Push to `main`:** The developer commits and pushes the change to the `main` branch.
3.  **Continuous Integration (CI):** The push triggers the `ci.yml` workflow, which automatically runs the `pytest` health check to ensure the application is stable.
4.  **Continuous Deployment (CD):** If the tests pass, the `deploy.yml` workflow triggers and performs the following:
    *   Builds a new Docker image from the application code.
    *   Pushes the new image to the ECR repository.
    *   Triggers a **zero-downtime rolling deployment** of the ECS service with the new image.

**Result:** Within minutes, the new version of the application is live and serving traffic, all without any manual intervention.

## 🧹 Destroying the Infrastructure

To avoid ongoing AWS charges, you should destroy the infrastructure when you are finished with the project. This must be done in the reverse order of creation.

1.  **Destroy the Main Infrastructure:**
    ```
    cd infra
    terraform destroy -var="weather_api_key=dummy" --auto-approve
    ```
2.  **Destroy the State Backend:**
    ```
    cd ../state
    terraform destroy --auto-approve
    ```
```

