provider "aws" {
  region = "us-east-1"
}

data "aws_iam_policy_document" "Polly_Full_Access" {
  statement {
    effect    = "Allow"
    actions   = ["polly:*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "S3_Full_Access" {
  statement {
    effect = "Allow"
    actions = ["s3:*",
      "s3-object-lambda:*"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "AWS_Lambda_Basic_ExecutionRole" {
  statement {
    effect = "Allow"
    actions = ["logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

