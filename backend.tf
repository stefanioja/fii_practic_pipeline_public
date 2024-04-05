provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket         = "s3-terraform-state-fii-practic-iuewygtiouwetf65"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}


# module "s3-terraform-state" {
#   source  = "cloudposse/s3-bucket/aws"
#   version = "3.1.3"

#   bucket_name        = "s3-terraform-state-fii-practic-iuewygtiouwetf65"
#   versioning_enabled = true
# }


# resource "aws_dynamodb_table" "terraform_state_lock" {
#   name         = "terraform-state-lock"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
#   tags = {
#     Environment = "CICD"
#     Name        = "FIIpractic"
#   }
# }
