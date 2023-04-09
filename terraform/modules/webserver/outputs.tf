# output "ec2_instance_public_ips" {
#   description = "Public IP addresses of EC2 instances"
#   value       = aws_launch_configuration.webserver[*].public_ip
# }

output "ec2_instance_ids" {
  description = "IDs of EC2 instances"
  value       = aws_launch_configuration.webserver[*].id
}
