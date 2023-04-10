
variable "project" {
  description = "The name of the project"
  default     = "Cv-React-App"
  type        = string
}

# variable "alb_target_group_name" {
#   description = "The name of the target group"
#   type        = string
# }

variable "asg_name" {
  description = "The name of the autoscaling group"
  type        = string
}

variable "code_deploy_role_arn" {
  description = "The ARN of the CodeDeploy role"
  type        = string
}
