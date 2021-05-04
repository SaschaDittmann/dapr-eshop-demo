resource "aws_ecr_repository" "webapp" {
  name                 = "${var.prefix}-webapp"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
