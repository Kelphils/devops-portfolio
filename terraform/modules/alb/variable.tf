variable "alb_tls_cert_arn" {
  description = "The ARN of the certificate that the ALB uses for https"
  type        = string
}

variable "project" {
  description = "The name of the project"
  default     = "Cv-React-App"
  type        = string
}
variable "alb_security_groups" {
  description = "Comma separated list of security groups"
  # type        = list(string)
}
