variable "project" {
  description = "The name of the project"
  default     = "Cv-React-App"
  type        = string
}

variable "host_header_domains" {
  description = "The host header domains"
  default     = ["cv.kelyinc.xyz"]
  type        = list(string)
}

variable "listener_arn" {
  description = "The ARN of the load balancer"
  type        = string
}

variable "listener_rule_priority" {
  description = "The priority of the listener rule"
  default     = 90
  type        = number
}


variable "health_check_protocol" {
  description = "Health check protocol e.g. HTTP"
  default     = "HTTP"
  type        = string
}

variable "health_check_matcher_code" {
  description = "Health check matcher code e.g. 200 for HTTP"
  default     = "200"
  type        = string
}

variable "protocol_version" {
  description = "The protocol version of the target group (HTTP1 or HTTP2)"
  default     = "HTTP1"
  type        = string
}

variable "deregistration_delay" {
  description = "The amount of time, in seconds, that the load balancer waits before deregistering a target"
  default     = 30
  type        = number
}
