
variable "key_name" {
  description = "Key to access the EC2 instance"
  type        = string
  default     = "mykeypair"
}

variable "security_groups" {
  description = "Comma separated list of security groups"
  # type        = list(string)
}
