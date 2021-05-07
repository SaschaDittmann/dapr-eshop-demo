resource "aws_sns_topic" "order" {
  name = "order"

  tags = {
    Name = "${var.prefix}-sns"
    App  = var.prefix
  }
}

resource "aws_sqs_queue" "orderservice" {
  name = "orderservice"

  tags = {
    Name = "${var.prefix}-sqs"
    App  = var.prefix
  }
}

resource "aws_sns_topic_subscription" "orderservice" {
  topic_arn = aws_sns_topic.order.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.orderservice.arn
}
