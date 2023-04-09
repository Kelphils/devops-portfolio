output "alb_sg_id" {
  value       = aws_security_group.alb_sg.id
  description = "The ID of the security group"
}

output "instance_sg_id" {
  value       = aws_security_group.instance_sg.id
  description = "The ID of the security group"
}
