variable "region" {
  type        = string
  description = "AWS region"
}

variable "prefix" {
  type        = string
  description = "The prefix used for naming the resources"
}

variable "eks_cluster_version" {
  type        = string
  default     = "1.19"
  description = "Kubernetes version supported by EKS. \n Reference: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html"
}

variable "eks_instance_type" {
  type        = string
  default     = "t2.small"
  description = "Instance type for the default EKS worker group"
}

variable "eks_max_worker_count" {
  type        = number
  default     = 10
  description = "Maximal number of nodes for the default EKS worker group"
}

variable "workers_additional_policies" {
  description = "Additional policies to be added to workers"
  type        = list(string)
  default     = []
}

variable "mysql_admin_username" {
  type        = string
  default     = "dapradmin"
  description = "MySQL Admin Username"
}

variable "mysql_admin_password" {
  type        = string
  description = "MySQL Admin Password"
}

variable "enable_aspnet_development" {
  type        = bool
  default     = false
  description = "Enable ASP.NET Core Development mode"
}

variable "sendgrid_api_key" {
  type        = string
  description = "Sendgrid API Key"
}

variable "sendgrid_from" {
  type        = string
  description = "Sendgrid 'Email From' value"
}

variable "default_email_to" {
  type        = string
  description = "Default 'Email To' address"
}
