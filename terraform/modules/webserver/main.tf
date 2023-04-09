data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
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

#  replace the instance with launch configuration to launch ec2 instances
resource "aws_launch_configuration" "webserver" {
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = "t3.medium"
  security_groups = [var.security_groups]
  key_name        = var.key_name

  # Render the User Data script as a template which is a bash script created in the current directory
  user_data = file("user-data.tpl")

  # Required when using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
  }
}

# create autoscaling group from the launch configuration
resource "aws_autoscaling_group" "webserver_group" {
  launch_configuration = aws_launch_configuration.webserver.name
  vpc_zone_identifier  = data.aws_subnets.default.ids

  target_group_arns = [var.aws_lb_target_group_arn]
  health_check_type = "ELB"

  min_size = 1
  max_size = 3

  tag {
    key                 = "Name"
    value               = "${var.project}-Asg-ManagedBy-Terraform"
    propagate_at_launch = true
  }
}
