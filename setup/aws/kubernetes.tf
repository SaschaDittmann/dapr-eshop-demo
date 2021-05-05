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

module "kubernetes" {
  source = "../kubernetes"

  image_webshop = "${aws_ecr_repository.webshop.repository_url}:latest"
  image_catalog = "${aws_ecr_repository.catalog.repository_url}:latest"

  depends_on = [
    null_resource.build_images,
    null_resource.deploy_dapr_components
  ]
}
