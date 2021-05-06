variable "mysql_admin_password" {
  type        = string
  default     = ""
  description = "Admin Password of the MySQL Database (Username root)"
}

variable "sendgrid_api_key" {
  type        = string
  description = "Sendgrid API Key"
}

variable "sendgrid_from" {
  type        = string
  description = "Sendgrid 'Email From' value"
}
