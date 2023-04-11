variable "codebuild_role" {
  description = "The ARN of the CodeBuild role"
  type        = string
}


variable "project" {
  description = "The name of the project"
  default     = "Cv-React-App"
  type        = string
}

# variable "security_group_id" {
#   description = "Comma separated list of security groups"
#   # type        = list(string)
# }
