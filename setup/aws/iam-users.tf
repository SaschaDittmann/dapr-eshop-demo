resource "aws_iam_user" "dapr" {
  name = var.prefix

  tags = {
    App = var.prefix
  }
}

resource "aws_iam_access_key" "dapr" {
  user = aws_iam_user.dapr.name
}

resource "aws_iam_user_policy_attachment" "sns" {
  user       = aws_iam_user.dapr.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

resource "aws_iam_user_policy_attachment" "sqs" {
  user       = aws_iam_user.dapr.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}
