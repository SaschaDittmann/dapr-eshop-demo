resource "aws_ecr_repository" "webshop" {
  name                 = "${var.prefix}-webshop"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
