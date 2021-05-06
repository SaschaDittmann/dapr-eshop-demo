variable "image_webshop" {
  type        = string
  description = "Docker Image for the eshop web app"
}

variable "replicas_webshop" {
  type        = number
  default     = 2
  description = "Number of replicas for the eshop web app"
}

variable "image_pull_policy_webshop" {
  type        = string
  default     = "Always"
  description = "Image Pull Policy for the eshop web app"
}

variable "image_catalog" {
  type        = string
  description = "Docker Image for the product catalog web api"
}

variable "replicas_catalog" {
  type        = number
  default     = 2
  description = "Number of replicas for the product catalog web api"
}

variable "image_pull_policy_catalog" {
  type        = string
  default     = "Always"
  description = "Image Pull Policy for the product catalog web api"
}
