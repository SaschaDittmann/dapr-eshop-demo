variable "mysql_admin_password" {
  type        = string
  default     = ""
  description = "Admin Password of the MySQL Database (Username root)"
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
