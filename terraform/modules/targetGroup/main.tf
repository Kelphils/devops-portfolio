locals {
  nginxPort = 80
  tags      = { Name = "${var.project}-ManagedBy-Terraform" }
}

# data to view subnet resources within the vpc
data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_lb_target_group" "main" {
  name                 = "${var.project}-target-group"
  port                 = local.nginxPort
  protocol             = "HTTP"
  vpc_id               = data.aws_vpc.default.id
  target_type          = "instance"
  deregistration_delay = var.deregistration_delay

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = var.health_check_protocol
    matcher             = var.health_check_matcher_code
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }

  tags = local.tags


}

resource "aws_lb_listener_rule" "main" {
  listener_arn = var.listener_arn
  priority     = var.listener_rule_priority

  condition {
    host_header {
      values = var.host_header_domains
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
  tags = local.tags
}
