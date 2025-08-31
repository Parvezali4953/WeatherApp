module "secrets" {
  source      = "./secrets"
  project     = var.project
  environment = var.environment
  region      = var.region
  api_key     = var.api_key
}

module "networking" {
  source      = "./networking"
  project     = var.project
  environment = var.environment
  region      = var.region
}

module "cloudwatch" {
  source      = "./cloudwatch"
  project     = var.project
  environment = var.environment
  region      = var.region
}

module "ecr" {
  source      = "./ecr"
  project     = var.project
  environment = var.environment
}

module "iam" {
  source      = "./iam"
  project     = var.project
  environment = var.environment
   # Pass secret ARN so exec role can read it
  weather_api_secret_arn   = module.secrets.weather_api_arn
}

module "alb" {
  source            = "./alb"
  project           = var.project
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  alb_sg_id         = module.networking.alb_sg_id
  target_port       = var.container_port
}

module "ecs" {
  source             = "./ecs"
  project            = var.project
  environment        = var.environment
  region             = var.region
  cluster_sg_id      = module.networking.app_sg_id
  public_subnet_ids  = module.networking.public_subnet_ids
  assign_public_ip   = true
  container_port     = var.container_port
  desired_count      = var.desired_count
  container_image    = var.container_image
  log_group_name     = module.cloudwatch.log_group_name
  execution_role_arn = module.iam.execution_role_arn
  target_group_arn   = module.alb.target_group_arn
  # Pass secret ARN to task definition
  weather_api_secret_arn = module.secrets.weather_api_arn
  depends_on         = [module.alb]
}
