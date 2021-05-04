module "eks" {
  source                      = "terraform-aws-modules/eks/aws"
  cluster_name                = local.cluster_name
  cluster_version             = var.eks_cluster_version
  subnets                     = module.vpc.private_subnets
  write_kubeconfig            = false
  workers_additional_policies = concat(var.workers_additional_policies, ["arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"])

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = var.eks_instance_type
      asg_min_size                  = 3
      asg_max_size                  = var.eks_max_worker_count
      asg_desired_capacity          = 3
      autoscaling_enabled           = true
      additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

resource "null_resource" "install_dapr" {
  provisioner "local-exec" {
    command = <<-EOT
      aws eks --region ${var.region} update-kubeconfig --name ${local.cluster_name}
      dapr init -k --enable-ha=true --wait
    EOT
  }

  depends_on = [
    module.eks
  ]
}
