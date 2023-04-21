locals {
  http_port = 80
  # server_port  = 80
  https_port   = 443
  any_port     = 0
  ssh_port     = 22
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
  ipv6_ips     = ["::/0"]


  tags = { Name = "${var.project}-Sg-ManagedBy-Terraform" }
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


# create a security group to allow traffic to the load balancer
resource "aws_security_group" "alb_sg" {
  name        = "${var.project}-alb_sg"
  description = "Allow inbound traffic to the load balancer"
  vpc_id      = data.aws_vpc.default.id
  tags        = local.tags
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTP inbound traffic on port 80"

  # Allow inbound HTTP requests
  from_port        = local.http_port
  to_port          = local.http_port
  protocol         = local.tcp_protocol
  cidr_blocks      = local.all_ips
  ipv6_cidr_blocks = local.ipv6_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTP inbound traffic to all ports"

  # Allow all outbound requests
  from_port        = local.any_port
  to_port          = local.any_port
  protocol         = local.any_protocol
  cidr_blocks      = local.all_ips
  ipv6_cidr_blocks = local.ipv6_ips
}

resource "aws_security_group_rule" "allow_https_inbound" {
  # count             = var.alb_tls_cert_arn != "" ? 1 : 0
  type              = "ingress"
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow TLS inbound traffic on port 443"

  # Allow inbound HTTPS requests
  from_port        = local.https_port
  to_port          = local.https_port
  protocol         = local.tcp_protocol
  cidr_blocks      = local.all_ips
  ipv6_cidr_blocks = local.ipv6_ips
}

# create a security group to allow web traffic to the instance
resource "aws_security_group" "instance_sg" {
  name        = "${var.project}-instance_sg"
  description = "SSH on port 22 and HTTP on port 80 for Nginx"
  vpc_id      = data.aws_vpc.default.id
  tags        = local.tags
}

resource "aws_security_group_rule" "allow_ssh_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instance_sg.id
  description       = "Allow SSH inbound traffic on port 22"

  # Allow inbound SSH requests
  from_port   = local.ssh_port
  to_port     = local.ssh_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# resource "aws_security_group_rule" "allow_nginx_inbound" {
#   type              = "ingress"
#   security_group_id = aws_security_group.instance_sg.id
#   description       = "Allow NGINX inbound traffic on port 80"

#   # Allow inbound HTTP requests for NGINX
#   from_port        = local.server_port
#   to_port          = local.server_port
#   protocol         = local.tcp_protocol
#   cidr_blocks      = local.all_ips
#   ipv6_cidr_blocks = local.ipv6_ips
# }

resource "aws_security_group_rule" "allow_all_instance_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.instance_sg.id
  description       = "Allow outbound traffic to all ports"

  # Allow all outbound requests
  from_port        = local.any_port
  to_port          = local.any_port
  protocol         = local.any_protocol
  cidr_blocks      = local.all_ips
  ipv6_cidr_blocks = local.ipv6_ips
}

resource "aws_security_group_rule" "allow_alb_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instance_sg.id
  description       = "Allow inbound traffic from the ALB security group"

  # Allow traffic from the ALB security group
  from_port                = local.http_port
  to_port                  = local.http_port
  protocol                 = local.tcp_protocol
  source_security_group_id = aws_security_group.alb_sg.id
}
