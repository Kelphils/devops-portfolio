# output "ec2_instance_public_ips" {
#   description = "Public IP addresses of EC2 instances"
#   value       = aws_launch_configuration.webserver[*].public_ip
# }

output "webserver_instance_ids" {
  description = "IDs of EC2 instances"
  value       = aws_autoscaling_group.webserver_group.id
}
output "asg_name" {
  description = "Name of autoscaling group"
  value       = aws_autoscaling_group.webserver_group.name
}
