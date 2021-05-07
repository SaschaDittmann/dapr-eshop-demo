resource "aws_ecr_repository" "webshop" {
  name                 = "${var.prefix}-webshop"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.prefix}-ecr-webshop"
    App  = var.prefix
  }
}

resource "aws_ecr_repository" "catalog" {
  name                 = "${var.prefix}-catalog"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.prefix}-ecr-catalogservice"
    App  = var.prefix
  }
}

resource "aws_ecr_repository" "orderservice" {
  name                 = "${var.prefix}-orderservice"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.prefix}-ecr-orderservice"
    App  = var.prefix
  }
}

resource "null_resource" "build_images" {
  provisioner "local-exec" {
    command = <<-EOT
      aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.webshop.repository_url}
      docker build -t ${aws_ecr_repository.webshop.repository_url}:latest ../../WebShop
      docker push ${aws_ecr_repository.webshop.repository_url}:latest

      aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.catalog.repository_url}
      docker build -t ${aws_ecr_repository.catalog.repository_url}:latest ../../CatalogService
      docker push ${aws_ecr_repository.catalog.repository_url}:latest

      aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.orderservice.repository_url}
      docker build -t ${aws_ecr_repository.orderservice.repository_url}:latest ../../OrderService
      docker push ${aws_ecr_repository.orderservice.repository_url}:latest
    EOT
  }
}
