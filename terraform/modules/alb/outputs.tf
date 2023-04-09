output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "The domain name of the load balancer"
}

output "alb_zone_id" {
  value       = aws_lb.main.zone_id
  description = "The zone id of the load balancer"
}

output "listener_arn" {
  value = element(compact((concat(
    aws_alb_listener.https[*].arn,
    aws_alb_listener.http[*].arn
  ))), 0)
  description = "The ARN of the listener"
}
