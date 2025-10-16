### Cloud‑Native DevOps on Pipeline (ECS Fargate + Terraform + GitHub Actions)
A small, end‑to‑end setup that containerizes a Python/Flask app, provisions AWS infrastructure with Terraform, deploys to ECS Fargate behind an ALB, and automates builds/deploys with GitHub Actions. It demonstrates containerization, IaC with remote state, CI/CD, health‑gated rollouts, and practical troubleshooting.

## Repository structure

app/: Flask app, Dockerfile, requirements.txt, tests/, exposes “/health” on port 5000.

infra/: Terraform root with components split by folder (networking, iam, ecr, ecs, alb, cloudwatch, secrets) and root files (main.tf, variables.tf, outputs.tf, provider/backend config).

.github/workflows/: deploy.yml (deploy pipeline), ci.yml (CI/tests).

state/: local Terraform working folder for plugins/locks if used during bootstrap; do not commit. Remote state is S3.

## Prerequisites

AWS account with permissions for ECR, ECS, ALB, IAM, CloudWatch, and an S3 bucket for Terraform remote state.

AWS CLI and Terraform installed.

GitHub repository with Actions enabled and repo variables/secrets configured (see CI/CD section).

## Quickstart: run the app locally

cd app

docker build -t weather-app:local .

docker run -p 5000:5000 weather-app:local

curl http://localhost:5000/health should return 200

## Infrastructure: initialize and apply (S3 remote state)

cd infra

Ensure backend settings (S3 bucket/key/region) are set in the backend/provider config.

terraform init

Review variables in variables.tf and terraform.tfvars.

terraform plan -var-file=terraform.tfvars

terraform apply -auto-approve

Get ALB DNS and verify:

terraform output -raw alb_dns

curl http://$(terraform output -raw alb_dns)/health should return 200

## Provisioning order (first time)

Networking (VPC, subnets, route tables) → IAM roles (task/execution) and logs → ECR → ECS cluster/task/service → ALB target group + listener → autoscaling (optional).

## Application container, port, and health check

The container listens on port 5000.

The ALB target group points to port 5000 and checks path /health for HTTP 200.

If health checks fail, confirm the path, port, and timeouts match the app and target group settings.

## CI/CD with GitHub Actions (deploy.yml)
Triggers

On push to main.

Manual trigger (workflow_dispatch) for first deploy/hotfix.

## Required repository configuration

Variables/secrets:

AWS_ACCOUNT_ID

AWS_REGION

ECR_REPO (e.g., weather-app)

Either:

OIDC (recommended): repository/environment configured to allow role assumption; workflow needs id‑token capability; provide AWS_ROLE_TO_ASSUME, or

Access keys: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY (least‑privilege).

If the workflow expects names as inputs/vars: ECS_CLUSTER, ECS_SERVICE.

Required permissions for OIDC mode: allow the workflow to request an ID token and read repository contents.

## What the deploy workflow does

Log in to ECR.

Build Docker image and tag with the commit SHA: <account>.dkr.ecr.<region>.amazonaws.com/<repo>:<sha>.

Push image to ECR.

Update ECS task/service to use the new image tag.

Wait for service stability.

Smoke‑test GET /health via the ALB to fail fast on bad rollouts.

## First deploy options

Manual run: Open the Actions tab and run the deploy workflow (workflow_dispatch) after Terraform creates ECR/ECS/ALB.

Or do a one‑time local build/push to seed ECR, then let push to main handle subsequent deploys.

## Operations and troubleshooting

503 during rollout:

ALB shows zero healthy targets or the app is slow to warm up.

Check ALB target health reason codes, confirm target group port is 5000, path is /health, and timeouts/thresholds are reasonable.

Service not stabilizing:

Check ECS service events and CloudWatch logs for container startup errors, port mismatches, or image pull failures.

Confirm the task execution role can pull from ECR and write logs.

CI cannot assume role:

In OIDC mode, ensure the workflow/environment is permitted by the role trust policy and that the workflow has the ID token permission enabled.

## State folder note (important)

This project uses an S3 backend for Terraform. The state/ directory is only a local working folder where Terraform may place .terraform/, locks, and temporary files during bootstrap. Do not run plans/applies from state/, and do not commit its contents. Run all Terraform commands from infra/. The authoritative state lives in S3 and is versioned there.

## Clean up

cd infra && terraform destroy

If decommissioning the environment entirely, delete the S3 state bucket last.

## What this demonstrates

Reproducible infrastructure via Terraform with remote state, containerized app with health checks, automated ECR/ECS deployments with stability waits, and practical ALB/CloudWatch troubleshooting—matching junior DevOps expectations.

## Optional enhancements

Add target‑tracking autoscaling (CPU/RequestCountPerTarget) for load tests.

Add alarms/dashboards in CloudWatch and environment protections/approvals for production branches.

Introduce OIDC‑based federation for CI/CD if not already used, and pin Actions by commit SHA.

## .gitignore recommendations (add to repo)

state/

**/.terraform/

**/terraform.tfstate

**/terraform.tfstate.backup

venv/

pycache/

*.pyc

.env

app/.pytest_cache/

## Notes :- 

Terraform commands are executed from infra/.

After apply, terraform output -raw alb_dns returns the ALB DNS for verification.

The app listens on 5000 and exposes /health; the ALB target group uses the same port/path.
