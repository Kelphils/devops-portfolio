variable "aws_lb_target_group_arn" {
  description = "ARN of the target group to attach to the autoscaling group"
  type        = string
}

variable "key_name" {
  description = "Key to access the EC2 instance"
  type        = string
  default     = "mykeypair"
}

variable "security_groups" {
  description = "Comma separated list of security groups"
  # type        = list(string)
}

variable "project" {
  description = "The name of the project"
  default     = "Cv-React-App"
  type        = string
}
