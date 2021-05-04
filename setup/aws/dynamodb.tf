resource "aws_dynamodb_table" "statestore" {
  name           = "${var.prefix}-statestore"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "key"

  attribute {
    name = "key"
    type = "S"
  }

  tags = {
    Name = "${var.prefix}-dynamodb"
  }
}
