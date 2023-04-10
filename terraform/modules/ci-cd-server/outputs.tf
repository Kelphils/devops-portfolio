output "ci_cd_instance_ids" {
  description = "IDs of EC2 instances"
  value       = aws_autoscaling_group.ci_cd_server_group.id
}
