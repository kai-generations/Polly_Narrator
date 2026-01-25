provider aws {
    region = "us-east-1"
}

data "aws_iam_policy_document" "Polly_Full_Access" {
    statement {
        effect = "Allow"
      actions = ["polly:*"]
      resources = ["*"]
    }
}

data "aws_iam_policy_document" "S3_Full_Access" {
    statement {
      effect = "Allow"
      actions = ["*"]
    }
}