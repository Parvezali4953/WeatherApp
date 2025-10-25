terraform {
  backend "s3" {
    # Replace with your actual S3 bucket name
    bucket         = "weatherapp-state-bucket" 
    # Key should be unique for this environment/module
    key            = "infra/terraform.tfstate"
    # Match the region used in deploy.yml
    region         = "ap-south-1" 
    encrypt        = true
    
    # This enables state locking
    dynamodb_table = "weather-prod-tf-locks" 
  }
}

provider "aws" {
  # This region variable is fine here as it's for the provider, not the backend block.
  region = var.region
}
