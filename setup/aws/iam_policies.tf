resource "aws_iam_policy" "eks_dapr" {
  name        = "eks_dapr_policy"
  path        = "/"
  description = "Access AWS Resources from EKS for the Dapr solution"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:*",
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.statestore.arn
      },
    ]
  })
}
