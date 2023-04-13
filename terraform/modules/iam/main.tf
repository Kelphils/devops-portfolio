data "aws_caller_identity" "default" {}

#EC2 Code deploy service role
resource "aws_iam_role" "ec2codedeploy_role" {
  name = "${var.project}_ec2_codedeploy_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name = "${var.project}-role-ManagedBy-Terraform"
  }

}

resource "aws_iam_role_policy_attachment" "AnazonEc2RoleforAWSCodeDeploy_attach" {
  role       = aws_iam_role.ec2codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_role_policy_attachment" "ec2_fullaccess_attach" {
  role       = aws_iam_role.ec2codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "ec2_s3_fullaccess_attach" {
  role       = aws_iam_role.ec2codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ec2_code_deploy_instance_profile" {
  name = "${var.project}_code_deploy_instance_profile"
  role = aws_iam_role.ec2codedeploy_role.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

#AWS Code Deploy Service Role
resource "aws_iam_role" "codedeploy_role" {
  name               = "${var.project}_codedeploy_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = {
    Name = "${var.project}-role-ManagedBy-Terraform"
  }

}

resource "aws_iam_role_policy_attachment" "codedeploy_attachment_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_role_policy_attachment" "codedeploy_s3_fullaccess_attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


#EC2 service role for cloud watch agent
resource "aws_iam_role" "ec2_cw_agent_role" {
  name = "${var.project}_ec2_cw_agent_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name = "${var.project}-role-ManagedBy-Terraform"
  }

}


resource "aws_iam_role_policy_attachment" "CW_Agent_attach" {
  role       = aws_iam_role.ec2_cw_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_cw_instance_profile" {
  name = "${var.project}_cw_agent_instance_profile"
  role = aws_iam_role.ec2_cw_agent_role.name
}

# CodeBuild Role
resource "aws_iam_role" "codebuildrole" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codebuild.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  description           = "Allows CodeBuild to call AWS services on your behalf."
  force_detach_policies = false
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ]
  max_session_duration = 3600
  name                 = "CodeBuildRole"

  inline_policy {
    name = "CodeBuild"
    policy = jsonencode(
      {
        Statement = [
          {
            Action = [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
            ]
            Effect = "Allow"
            Resource = [
              "*",
            ]
          },
          {
            Action = [
              "s3:PutObject",
              "s3:GetObject",
              "s3:GetObjectVersion",
              "s3:GetBucketAcl",
              "s3:GetBucketLocation",
            ]
            Effect = "Allow"
            Resource = [
              "arn:aws:s3:::codepipeline-us-east-1-*",
            ]
          },

          {
            Action = [
              "codebuild:CreateReportGroup",
              "codebuild:CreateReport",
              "codebuild:UpdateReport",
              "codebuild:BatchPutTestCases",
              "codebuild:BatchPutCodeCoverages",
            ]
            Effect = "Allow"
            Resource = [
              "*",
            ]
          },
          # Uncomment this block to allow CodeBuild to create and manage VPC resources
          # {
          #   "Effect" : "Allow",
          #   "Action" : [
          #     "ec2:CreateNetworkInterface",
          #     "ec2:DescribeDhcpOptions",
          #     "ec2:DescribeNetworkInterfaces",
          #     "ec2:DeleteNetworkInterface",
          #     "ec2:DescribeSubnets",
          #     "ec2:DescribeSecurityGroups",
          #     "ec2:DescribeVpcs"
          #   ],
          #   "Resource" : "*"
          # },
          # {
          #   "Effect" : "Allow",
          #   "Action" : [
          #     "ec2:CreateNetworkInterfacePermission"
          #   ],
          #   "Resource" : "*",
          # },
        ]
        Version = "2012-10-17"
      }
    )
  }
  tags = { Name = "${var.project}-role-ManagedBy-Terraform" }
}


# CodePipeline Role
resource "aws_iam_role" "codepipeline" {
  name               = "CodePipelineRole"
  assume_role_policy = data.aws_iam_policy_document.cp_assume_role_policy.json
}

data "aws_iam_policy_document" "cp_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com", "codebuild.amazonaws.com", "codedeploy.amazonaws.com", "ec2.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.default.account_id}:root"]
    }
  }
}


resource "aws_iam_role_policy" "codepipelinerole_policy" {
  name = "CodepipelineRole-Policy"
  role = aws_iam_role.codepipeline.id

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "codestar-connections:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketVersioning"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::*",
                "arn:aws:s3:::*/*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "elasticbeanstalk:*",
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "cloudwatch:*",
                "s3:*",
                "sns:*",
                "cloudformation:*",
                "rds:*",
                "sqs:*",
                "ecs:*",
                "iam:PassRole"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "lambda:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "opsworks:CreateDeployment",
                "opsworks:DescribeApps",
                "opsworks:DescribeCommands",
                "opsworks:DescribeDeployments",
                "opsworks:DescribeInstances",
                "opsworks:DescribeStacks",
                "opsworks:UpdateApp",
                "opsworks:UpdateStack"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStacks",
                "cloudformation:UpdateStack",
                "cloudformation:CreateChangeSet",
                "cloudformation:DeleteChangeSet",
                "cloudformation:DescribeChangeSet",
                "cloudformation:ExecuteChangeSet",
                "cloudformation:SetStackPolicy",
                "cloudformation:ValidateTemplate",
                "iam:PassRole"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}
