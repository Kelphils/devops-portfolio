output "codebuild_project_name" {
  value = aws_codebuild_project.build_react.name
}

output "kms_alias_key_arn" {
  value = aws_kms_alias.codebuild.arn

}
