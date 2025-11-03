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
  secrets_manager_secret_arn = module.secrets.secret_arn
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
  vpc_id            = module.networking.vpc_id  
  public_subnet_ids = module.networking.public_subnet_ids  
  alb_sg_id         = module.networking.alb_sg_id  
  container_port    = var.container_port
}

module "ecs" {
  source = "./ecs"

  project_name                = var.project_name
  environment                 = var.environment
  aws_region                  = var.aws_region
  private_subnet_ids          = module.networking.private_subnet_ids  
  ecs_sg_id                   = module.networking.ecs_tasks_sg_id  
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn  
  ecs_task_role_arn           = module.iam.ecs_task_role_arn  
  alb_target_group_arn        = module.alb.target_group_arn  
  alb_listener                = module.alb.listener
  container_image             = var.container_image
  container_port              = var.container_port
  secret_arn                  = module.secrets.secret_arn
  log_group_name              = module.cloudwatch.log_group_name
}
