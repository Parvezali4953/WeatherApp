# This is the root module, responsible for orchestrating all the child modules
# that create the various parts of our infrastructure.

# --- Provider Configuration ---
# Specifies the AWS provider and the default region for all resources.
provider "aws" {
  region = var.aws_region
}


# --- Child Modules ---
# Each "module" block instantiates a child module defined in a subdirectory.

module "networking" {
  source = "./networking"

  project_name   = var.project_name
  environment    = var.environment
  aws_region     = var.aws_region
  container_port = var.container_port
}

module "iam" {
  source = "./iam"

  project_name = var.project_name
  environment  = var.environment
}

module "ecr" {
  source = "./ecr"

  project_name = var.project_name
  environment  = var.environment
}

module "cloudwatch" {
  source = "./cloudwatch"

  project_name = var.project_name
  environment  = var.environment
}

module "secrets" {
  source = "./secrets"

  project_name    = var.project_name
  environment     = var.environment
  weather_api_key = var.weather_api_key
}

module "alb" {
  source = "./alb"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.networking.vpc_id # <-- Uses output from networking module
  public_subnet_ids = module.networking.public_subnet_ids # <-- Uses output
  alb_sg_id         = module.networking.alb_sg_id # <-- Uses output
  container_port    = var.container_port
}

module "ecs" {
  source = "./ecs"

  project_name                = var.project_name
  environment                 = var.environment
  aws_region                  = var.aws_region
  private_subnet_ids          = module.networking.private_subnet_ids # <-- Uses output
  ecs_sg_id                   = module.networking.ecs_tasks_sg_id # <-- Uses output
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn # <-- Uses output from iam module
  ecs_task_role_arn           = module.iam.ecs_task_role_arn # <-- Uses output
  alb_target_group_arn        = module.alb.target_group_arn # <-- Uses output from alb module
  alb_listener                = module.alb.listener
  container_image             = var.container_image
  container_port              = var.container_port
}
