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

variable "max_agent_count" {
  type        = number
  description = "Maximal number of nodes for the default AKS node pool"
}

variable "agent_vm_size" {
  type        = string
  description = "VM size for the default AKS node pool"
}
