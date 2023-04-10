# data "aws_caller_identity" "current" {}

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

resource "aws_iam_role_policy_attachment" "ec2_fullaccess_attach" {
  role       = aws_iam_role.ec2codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "ec2_s3_fullaccess_attach" {
  role       = aws_iam_role.ec2codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

#AWS Code Deploy Service Role
resource "aws_iam_role" "codedeploy_role" {
  name = "${var.project}_codedeploy_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Name = "${var.project}-role-ManagedBy-Terraform"
  }

}

resource "aws_iam_role_policy_attachment" "codedeploy_attachment_role" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_instance_profile" "ec2_code_deploy_instance_profile" {
  name = "${var.project}_code_deploy_instance_profile"
  role = aws_iam_role.ec2codedeploy_role.name
}

resource "aws_codedeploy_app" "react_app" {
  name             = "${var.project}-code-deploy-app"
  compute_platform = "Server"
}

resource "aws_sns_topic" "react_app_sns" {
  name = "${var.project}-sns-topic"
}

resource "aws_codedeploy_deployment_config" "app_config" {
  deployment_config_name = "CodeDeployDefault2.EC2AllAtOnce"

  #traffic_routing_config {
  #  type = "AllAtOnce"
  #}
  # Terraform: Should be "null" for EC2/Server

  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 0
  }
}

resource "aws_codedeploy_deployment_group" "cd_dg" {
  app_name              = aws_codedeploy_app.react_app.name
  deployment_group_name = "${aws_codedeploy_app.react_app.name}-group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn


  trigger_configuration {
    trigger_events = ["DeploymentFailure", "DeploymentSuccess", "DeploymentFailure", "DeploymentStop",
    "InstanceStart", "InstanceSuccess", "InstanceFailure"]
    trigger_name       = "event-trigger"
    trigger_target_arn = aws_sns_topic.react_app_sns.arn
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  alarm_configuration {
    alarms  = ["my-alarm-name"]
    enabled = true
  }

  #   load_balancer_info {
  #     target_group_info {
  #       name = var.alb_target_group_name
  #     }
  #   }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  autoscaling_groups = [var.asg_name]
}
