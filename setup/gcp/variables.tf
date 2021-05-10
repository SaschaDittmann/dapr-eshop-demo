variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "geography" {
  type        = string
  default     = "US"
  description = "Default GCP Zone"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "Default GCP Region"
}

variable "zone" {
  type        = string
  default     = "us-central1-c"
  description = "Default GCP Zone"
}

variable "prefix" {
  type        = string
  description = "The prefix used for naming the resources"
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
