variable "location" {
  type        = string
  description = "The location of the resource group as well as the resources"
}

variable "prefix" {
  type        = string
  description = "The prefix used for naming the resources"
}

variable "prefix_nospecialchars" {
  type        = string
  description = "The prefix used for naming the resources without any special charaters"
}

variable "dns_aks" {
  type        = string
  description = "The dns name for the Azure Kubernetes Service"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.19.9"
  description = "The version of kubernetes to use for the Azure Kubernetes Service"
}

variable "max_agent_count" {
  type        = number
  default     = 10
  description = "Maximal number of nodes for the default AKS node pool"
}

variable "agent_vm_size" {
  type        = string
  default     = "Standard_DS2_v2"
  description = "VM size for the default AKS node pool"
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
