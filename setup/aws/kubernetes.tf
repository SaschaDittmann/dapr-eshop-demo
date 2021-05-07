resource "null_resource" "deploy_dapr_components" {
  provisioner "local-exec" {
    command = <<-EOT
      kubectl config use-context '${module.eks.cluster_arn}'
      kubectl apply -f components/.
    EOT
  }

  depends_on = [
    null_resource.install_dapr
  ]
}

resource "kubernetes_secret" "dynamodb" {
  metadata {
    name = "aws-dynamodb"
  }
  data = {
    table  = "${aws_dynamodb_table.statestore.name}"
    region = "${var.region}"
  }
  type = "Opaque"
}

resource "kubernetes_secret" "catalog_mysql" {
  metadata {
    name = "catalog-mysql"
  }
  data = {
    url = "${aws_db_instance.mysql.username}:${var.mysql_admin_password}@tcp(${aws_db_instance.mysql.endpoint})/catalog?allowNativePasswords=true"
  }
  type = "Opaque"
}

resource "kubernetes_secret" "email" {
  metadata {
    name = "sendgrid"
  }
  data = {
    api-key    = var.sendgrid_api_key
    email-from = var.sendgrid_from
  }
  type = "Opaque"
}

resource "kubernetes_secret" "snssqs" {
  metadata {
    name = "aws-snssqs"
  }
  data = {
    access-key = aws_iam_access_key.dapr.id
    secret-key = aws_iam_access_key.dapr.secret
    region     = "${var.region}"
  }
  type = "Opaque"

  depends_on = [
    aws_sns_topic_subscription.orderservice
  ]
}

module "kubernetes" {
  source = "../kubernetes"

  image_webshop             = "${aws_ecr_repository.webshop.repository_url}:latest"
  image_catalog             = "${aws_ecr_repository.catalog.repository_url}:latest"
  image_orderservice        = "${aws_ecr_repository.orderservice.repository_url}:latest"
  enable_aspnet_development = var.enable_aspnet_development

  depends_on = [
    null_resource.build_images,
    null_resource.deploy_dapr_components,
    kubernetes_secret.dynamodb,
    kubernetes_secret.catalog_mysql,
    kubernetes_secret.email,
    kubernetes_secret.snssqs,
    aws_vpc_endpoint.dynamodb,
    aws_vpc_endpoint.rds,
    aws_vpc_endpoint.rds_data,
    aws_vpc_endpoint.sns,
    aws_vpc_endpoint.sqs,
  ]
}
