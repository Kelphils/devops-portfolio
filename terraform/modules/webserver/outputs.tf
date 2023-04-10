# output "ec2_instance_public_ips" {
#   description = "Public IP addresses of EC2 instances"
#   value       = aws_launch_configuration.webserver[*].public_ip
# }

output "launch_config_id" {
  description = "ID of launch configuration"
  value       = aws_launch_configuration.webserver[*].id
}
