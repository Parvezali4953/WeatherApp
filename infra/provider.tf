terraform {
  backend "s3" {
    bucket         = "weatherapp-state-bucket"
    key            = "infra/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "weatherapp-lock_table"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}
