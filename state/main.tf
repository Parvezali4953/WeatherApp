# PURPOSE: This configuration creates the necessary infrastructure for Terraform's
#          remote state backend. It should be run ONCE using a local state file
#          before the main infrastructure is deployed.
#
provider "aws" {
  region = var.aws_region
}

# Creates the S3 bucket that will store the terraform.tfstate file.
resource "aws_s3_bucket" "tf_state" {
  bucket = var.state_bucket_name

  tags = {
    Name = "${var.project_name}-${var.environment}-tf-state-bucket"
  }
}

# Best Practice: Enable versioning on the state bucket to protect against
# accidental deletion or state file corruption.
resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Best Practice: Block all public access to the state bucket. The state file
# can contain sensitive information, so it must be kept private.
resource "aws_s3_bucket_public_access_block" "tf_state_public_access" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Creates the DynamoDB table used for state locking. This prevents multiple
# users or CI/CD jobs from running 'apply' at the same time.
resource "aws_dynamodb_table" "tf_locks" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST" # Most cost-effective choice for this use case.
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S" # String
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-tf-locks"
  }
}
