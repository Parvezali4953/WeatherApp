# 1. State Bucket (S3)
# Creates the S3 bucket to store the remote state file.
resource "aws_s3_bucket" "tf_state" {
  bucket = var.state_bucket # Assumed to be passed via main.tf or env var
  tags = {
    Name        = "${var.project}-${var.environment}-tf-state"
    Environment = var.environment
  }
}

# Ensure data durability by enabling versioning (for rollback/recovery)
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Ensure maximum security by blocking all public access
resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# 2. State Lock Table (DynamoDB)
# Creates a DynamoDB table for state locking. This is mandatory for collaboration.
resource "aws_dynamodb_table" "tf_locks" {
  name         = "${var.project}-${var.environment}-tf-locks"
  billing_mode = "PAY_PER_REQUEST" # Cost-effective on-demand billing
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S" # String type for the lock identifier
  }

  tags = {
    Name        = "${var.project}-${var.environment}-tf-locks"
    Environment = var.environment
  }
}
