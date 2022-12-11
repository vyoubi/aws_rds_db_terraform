variable "region" {
  default     = "eu-central-1"
  description = "AWS region"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
}
