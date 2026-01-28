provider "aws" {
  region = "us-east-1"
}

# The locals block is used to list which AWS policies will be used; added service-role to the BasicExecutionRole since it is a service role is part of the arn after policy/
locals {
  managed_policies = [
    "AmazonPollyFullAccess",
    "AmazonS3FullAccess",
    "service-role/AWSLambdaBasicExecutionRole"
  ]
}

# This block will package the Lambda function code; will require archive provider
data "archive_file" "javascript_polly_lambda" {
  type        = "zip"
  source_file = "${path.module}/textToSpeech.js" # ${path.module} is a dynamic pointer that always identifies the filesystem path of the specific folder where the .tf files be written are
  output_path = "${path.module}/textToSpeech.zip"
}

# This block will create an S3 bucket
resource "aws_s3_bucket" "polly_audio_storage" {
  region        = "us-east-1"
  force_destroy = true
}

# This resource creates the lambda role 
resource "aws_iam_role" "lambda_role" {
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

  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

# This block will create a Lambda function
resource "aws_lambda_function" "lambda_polly_service" {
  function_name = "TTStranslatorfunction"
  role          = aws_iam_role.lambda_role.arn
  filename      = data.archive_file.javascript_polly_lambda.output_path

  runtime = "node.js22.x"
}