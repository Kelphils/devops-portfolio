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
resource "aws_launch_configuration" "ci_cd_server" {
  image_id                    = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  security_groups             = [var.security_groups]
  key_name                    = var.key_name
  associate_public_ip_address = true

  # Render the User Data script as a template which is a bash script created in the current directory
  user_data = file("codedeploy_agent_install.sh")

  # Required when using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
  }
}

# create autoscaling group from the launch configuration
resource "aws_autoscaling_group" "ci_cd_server_group" {
  launch_configuration = aws_launch_configuration.ci_cd_server.name
  vpc_zone_identifier  = data.aws_subnets.default.ids

  health_check_type = "EC2"

  min_size = 1
  max_size = 1


  tag {
    key                 = "Name"
    value               = "Code-Deploy-Server-ManagedBy-Terraform"
    propagate_at_launch = true
  }
}
