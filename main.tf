provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "lamda_role" {
  name = "PollyTranslationRole"
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