# output "ec2_instance_public_ips" {
#   description = "Public IP addresses of EC2 instances"
#   value       = aws_launch_configuration.webserver[*].public_ip
# }

output "launch_config_id" {
  description = "ID of launch configuration"
  value       = aws_launch_configuration.webserver[*].id
}

output "asg_name" {
  description = "Name of autoscaling group"
  value       = aws_autoscaling_group.webserver_group.name
}
