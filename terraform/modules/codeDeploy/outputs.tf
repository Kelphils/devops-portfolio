output "codedeploy_app_name" {
  value = aws_codedeploy_app.react_app.name
}

output "codedeploy_group_name" {
  value = aws_codedeploy_deployment_group.cd_dg.deployment_group_name
}
