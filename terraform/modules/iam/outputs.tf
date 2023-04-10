output "codedeploy_role_arn" {
  description = "ARN of CodeDeploy role"
  value       = aws_iam_role.codedeploy_role.arn
}

output "codedeploy_instance_profile" {
  description = "Name of CodeDeploy instance profile"
  value       = aws_iam_instance_profile.ec2_code_deploy_instance_profile.name
}

output "cw_agent_instance_profile" {
  description = "Name of CloudWatch instance profile"
  value       = aws_iam_instance_profile.ec2_cw_instance_profile.name
}
