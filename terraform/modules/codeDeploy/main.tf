# data "aws_caller_identity" "current" {}

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
  service_role_arn      = var.code_deploy_role_arn


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

  # deployment_style {
  #   deployment_option = "WITH_TRAFFIC_CONTROL"
  #   deployment_type   = "IN_PLACE"
  # }

  autoscaling_groups = [var.asg_name]

  tags = { Name = "${var.project}-Codedeploy-ManagedBy-Terraform" }
}
