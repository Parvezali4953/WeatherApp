# **Cloud-Native DevOps Pipeline: Flask App on AWS ECS Fargate**

A complete, production-style project demonstrating end-to-end **Continuous Deployment (CD)** of a containerized application to **AWS ECS Fargate**, orchestrated by **Terraform** and automated via **GitHub Actions**.

The core value of this project is demonstrating **reproducible infrastructure**, **zero-downtime deployment capabilities**, and practical **DevOps troubleshooting** (e.g., private networking access).

## **🚀 Key Technologies & Cloud Services**

| Category | Tools & Services | Description |
| :---- | :---- | :---- |
| **Infrastructure as Code (IaC)** | **Terraform** | Provisioned the entire AWS environment: VPC, Subnets, ALB, ECR, ECS Cluster, and Fargate Service. Implemented **S3 Remote State** with locking. |
| **Cloud Platform** | **AWS** (ECS Fargate, ALB, ECR, VPC, S3, IAM, CloudWatch) | Utilized serverless container orchestration (Fargate) for scalable and cost-effective hosting. |
| **CI/CD** | **GitHub Actions** | Automated image build, push to ECR, and forced ECS Service deployment upon every commit. |
| **Containerization** | **Docker** (Multi-Stage Build) | Containerized a Python/Flask application with a dedicated /health endpoint for stability and health checks. |
| **Networking & Security** | **VPC** (Public/Private), **ALB**, **Secrets Manager** | Secured API keys and configured the Application Load Balancer (ALB) to handle traffic distribution and health checks. |

## **📂 Repository Structure**

| Directory/File | Description |
| :---- | :---- |
| app/ | Contains the Python/Flask application, Dockerfile, dependencies, and the crucial /health endpoint. |
| infra/ | **Terraform Root Module.** Contains all .tf files logically split (e.g., vpc.tf, ecs.tf, alb.tf). **Run all Terraform commands from this directory.** |
| .github/workflows/ | Contains deploy.yml (the CD pipeline) and ci.yml (the CI/test pipeline). |
| state/ | **Local working folder.** Contains temporary files and Terraform cache. **Not committed to Git.** The authoritative state is secured in AWS S3. |

## **🛠 Quickstart & Deployment Steps**

### **1\. Prerequisites**

1. **AWS Account** with sufficient permissions for ECS, ECR, VPC, ALB, and IAM.  
2. **AWS CLI** and **Terraform** installed locally.  
3. **GitHub Secrets** configured for your AWS Access Key (AWS\_ACCESS\_KEY\_ID, AWS\_SECRET\_ACCESS\_KEY, AWS\_REGION).

### **2\. Infrastructure Deployment (Run Once)**

Navigate to the infra/ directory.

1. **Initialize Terraform:**  
   terraform init

2. **Plan and Apply:** Review the plan and provision the resources.  
   terraform plan  
   terraform apply

   *Note: The S3 backend bucket and DynamoDB lock table must be manually created first, as defined in backend.tf.*

### **3\. Application Deployment (Automated)**

* The infrastructure deployment creates the ECR repository.  
* The **GitHub Actions pipeline** takes over from here:  
  1. Upon a push to the main branch, the deploy.yml workflow triggers.  
  2. It builds the Docker image and pushes it to the provisioned ECR repository.  
  3. It updates the ECS Service with the new image tag, triggering a **rolling update (zero-downtime deployment)**.

### **4\. Verification**

After a successful deployment, retrieve the application URL:

cd infra  
terraform output \-raw alb\_dns

Access the returned URL in your browser to view the application. The /health endpoint is used internally for stability checks.

## **💡 What This Project Demonstrates**

* **IaC Proficiency:** Complete, version-controlled provisioning of a complex architecture using Terraform with secure S3 remote state.  
* **Networking Mastery:** Successful deployment into a private subnet and resolution of egress issues using a NAT Gateway (implied by the VPC setup).  
* **Reliability:** Usage of **ALB health checks** and **ECS Deployment Circuit Breakers** to ensure service stability and automatic rollback on failure.  
* **Security Best Practices:** Managing sensitive API keys using **AWS Secrets Manager** and integrating IAM for least-privilege access.

## **✅ Optional Enhancements (Future Work)**

1. **Autoscaling:** Add target-tracking autoscaling policies (e.g., RequestCountPerTarget) for real-world load management.  
2. **Security Scanning:** Integrate Trivy or an equivalent scanner into the CI/CD pipeline to scan the Docker image for vulnerabilities before pushing to ECR.  
3. **Advanced Monitoring:** Set up CloudWatch Alarms on ALB 5xx errors to notify a channel (e.g., Slack) for proactive incident response.

