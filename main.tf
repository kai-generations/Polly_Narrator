provider "aws" {
  region = "us-east-1"
}

# The locals block is used to list which AWS policies will be used
locals {
  managed_policies = [
    "AmazonPollyFullAccess",
    "AmazonS3FullAccess",
    "AWSLambdaBasicExecutionRole"
  ]
}

# This resource creates the lambda role 
resource "aws_iam_role" "lamda_role" {
  name                  = "PollyTranslationRole"
  force_detach_policies = true
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
    }]
  })
}

# This block attaches the managed policies to our lambda role
resource "aws_iam_role_policy_attachment" "lambda_permissions" {
  for_each = toset(local.managed_policies)

  role       = "aws_iam_role.lamda_role"
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}