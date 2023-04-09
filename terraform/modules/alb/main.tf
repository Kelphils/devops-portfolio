locals {
  http_port    = 80
  https_port   = 443
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]

  alb_http_default_action = {
    type             = var.alb_tls_cert_arn != "" ? "redirect" : "fixed-response"
    target_group_arn = null
    redirect = var.alb_tls_cert_arn != "" ? [{
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }] : []
    fixed_response = var.alb_tls_cert_arn != "" ? [] : [{
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = "404"
    }]
  }

  tags = { Name = "${var.project}-ManagedBy-Terraform" }

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

resource "aws_lb" "main" {
  name               = "${var.project}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_groups]
  subnets            = data.aws_subnets.default.ids

  enable_deletion_protection = false
  tags                       = local.tags
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = local.alb_http_default_action.type
    target_group_arn = local.alb_http_default_action.target_group_arn

    dynamic "redirect" {
      for_each = local.alb_http_default_action.redirect
      iterator = redir
      content {
        port        = redir.value["port"]
        protocol    = redir.value["protocol"]
        status_code = redir.value["status_code"]
      }
    }

    dynamic "fixed_response" {
      for_each = local.alb_http_default_action.fixed_response
      iterator = fr
      content {
        content_type = fr.value["content_type"]
        message_body = fr.value["message_body"]
        status_code  = fr.value["status_code"]
      }
    }

  }
  tags = local.tags
}

resource "aws_alb_listener" "https" {
  count             = var.alb_tls_cert_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.main.id
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.alb_tls_cert_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
  tags = local.tags
}
