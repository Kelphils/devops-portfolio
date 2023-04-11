data "aws_caller_identity" "default" {}

data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
resource "aws_kms_alias" "codebuild" {
  name          = "alias/key/${var.project}"
  target_key_id = aws_kms_key.codebuild.key_id
}

resource "aws_kms_key" "codebuild" {
  description         = "Default master key that protects my S3 objects when no other key is defined"
  enable_key_rotation = true
  policy = jsonencode(
    {
      Id = "auto-s3"
      Statement = [
        {
          Action = [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey",
          ]
          Condition = {
            StringEquals = {
              "kms:CallerAccount" = ["${data.aws_caller_identity.default.account_id}"]
              "kms:ViaService"    = "s3.us-east-1.amazonaws.com"
            }
          }
          Effect = "Allow"
          Principal = {
            AWS = "*"
          }
          Resource = "*"
          Sid      = "Allow access through S3 for all principals in the account that are authorized to use S3"
        },
        {
          Action = [
            "kms:*",
          ]
          Effect = "Allow"
          Principal = {
            AWS = ["arn:aws:iam::${data.aws_caller_identity.default.account_id}:root"]
          }
          Resource = "*"
          Sid      = "Allow direct access to key metadata to the account"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags = { Name = "${var.project}-Kms-ManagedBy-Terraform" }
}

resource "aws_codebuild_project" "CodeBuild_Project" {
  name           = "${var.project}-codebuild-project"
  encryption_key = aws_kms_key.codebuild.arn
  service_role   = var.codebuild_role

  artifacts {
    name                   = "${var.project}-codebuild-artifact"
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    image_pull_credentials_type = "CODEBUILD"
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    # CHANGE TO ENABLED TO ENABLE CLOUDWATCH LOGS
    cloudwatch_logs {
      group_name  = "${aws_codebuild_project.CodeBuild_Project.name}-log-group"
      stream_name = "${aws_codebuild_project.CodeBuild_Project.name}-log-stream"
      status      = "DISABLED"
    }
  }

  source {
    git_clone_depth = 0
    type            = "CODEPIPELINE"
  }

  # UNCOMMENT THIS SECTION TO USE GITHUB AS SOURCE
  # source {
  #   type            = "GITHUB"
  #   location        = "https://github.com/Kelphils/devops-portfolio.git"
  #   git_clone_depth = 1

  #   git_submodules_config {
  #     fetch_submodules = true
  #   }
  # }

  # source_version = "master"

  # UNCOMMENT THIS SECTION TO SPECIFY VPC CONFIGURATION, ALSO UPDATE THE IAM ROLE TO ALLOW ACCESS TO THE VPC RESOURCES
  # vpc_config {
  #   vpc_id = data.aws_vpc.default.id

  #   subnets = [
  #     data.aws_subnets.default.ids[0]
  #   ]

  #   security_group_ids = [
  #     var.security_group_id
  #   ]
  # }
  tags = { Name = "${var.project}-Codebuild-ManagedBy-Terraform" }
}



