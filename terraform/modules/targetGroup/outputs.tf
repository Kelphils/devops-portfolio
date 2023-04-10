output "target_group_arn" {
  value       = aws_lb_target_group.main.arn
  description = "The ARN of the target group"
}

output "target_group_name" {
  value       = aws_lb_target_group.main.name
  description = "The name of the target group"
}
