variable "project" {
  description = "The name of the project"
  default     = "Cv-React-App"
  type        = string
}

variable "alb_tls_cert_arn" {
  description = "The ARN of the certificate to use for HTTPS"
  type        = string
}
