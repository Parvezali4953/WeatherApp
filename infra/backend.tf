terraform {
  # This block configures the "backend," which tells Terraform where to store
  # its state file. Using a remote backend is essential for any team project
  # and a best practice for individual projects.
  backend "s3" {
    # The S3 bucket where the Terraform state file will be stored.
    # This bucket must be created manually beforehand.
    bucket = "my-unique-weather-app-tf-state-2025" # <-- Use a globally unique name

    # The path to the state file within the S3 bucket.
    key = "prod/infra/terraform.tfstate"

    # The AWS region where the S3 bucket and DynamoDB table exist.
    region = "ap-south-1"

    # Encrypts the state file at rest in S3, a critical security measure.
    encrypt = true

    # Enables state locking by using a DynamoDB table. This prevents multiple
    # people from running 'terraform apply' at the same time, which can
    # corrupt the state.
    dynamodb_table = "terraform-state-locks"
  }
}
