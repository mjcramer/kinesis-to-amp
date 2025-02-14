
terraform {
  # backend "s3" {
  #   bucket         = "adobe-terraform-magdamteam-bucket"
  #   key            = "global/cloudwatch-metrics-in-amp"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-lock-table"
  # }
  backend "s3" {
    bucket         = "cramer-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "cramer-terraform-state"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.86"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "default"

  default_tags {
    tags = {
      Environment = var.environment
      Project     = local.project_name
      Owner       = var.owner
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "metrics_bucket" {
  bucket = "${var.prefix}-metrics-data"
  tags = {
    Name    = "${var.prefix}-metrics-data"
    Purpose = "CloudWatch metrics storage"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl
# resource "aws_s3_bucket_acl" "bucket_acl" {
#   bucket = aws_s3_bucket.test_bucket.id
#   acl    = "private"
# }
# resource "aws_s3_bucket_policy" "firehose_policy" {
#   bucket = aws_s3_bucket.firehose_bucket.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect    = "Allow"
#         Principal = { Service = "firehose.amazonaws.com" }
#         Action    = "s3:PutObject"
#         Resource  = "${aws_s3_bucket.firehose_bucket.arn}/*"
#       }
#     ]
#   })
# }

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "project_logs" {
  name              = "${var.prefix}-project-logs"
  retention_in_days = var.project_logs_retention_in_days
}
