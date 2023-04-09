# variable "domain_name" {
#   description = "The domain name of the hosted zone"
#   type        = string
# }


variable "alb_dns_name" {
  description = "The domain name of the load balancer"
  type        = string
}

variable "alb_zone_id" {
  description = "The zone id of the load balancer"
  type        = string
}

variable "root_domain_name" {
  default = "cv.kelyinc.xyz"
}

variable "www_domain_name" {
  default = "www.cv.kelyinc.xyz"
}
