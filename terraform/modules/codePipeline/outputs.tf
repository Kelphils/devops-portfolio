output "s3_bucket" {
  value = aws_s3_bucket.codepipeline_bucket.id
}

output "codestar_arn" {
  value = aws_codestarconnections_connection.github_codepipeline.arn
}

output "codepipeline_name" {
  value = aws_codepipeline.pipeline.name
}
