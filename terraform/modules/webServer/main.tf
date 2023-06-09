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
  image_id                    = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  security_groups             = [var.security_groups]
  iam_instance_profile        = var.instance_profile
  key_name                    = var.key_name
  associate_public_ip_address = true
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = 10
    volume_type           = "gp2"
    delete_on_termination = true

  }
  # Render the User Data script as a template which is a bash script created in the current directory
  user_data = file("user-data.tpl")
  # user_data_replace_on_change = true

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
  health_check_type = "EC2"

  min_size = 1
  max_size = 3
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  tag {
    key                 = "Name"
    value               = "${var.project}-Instance-ManagedBy-Terraform"
    propagate_at_launch = true
  }
}


#ASG Scale-up Policy
resource "aws_autoscaling_policy" "web_asg_policy_up" {
  name                   = "${var.project}_web_asg_policy_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.webserver_group.name
}

resource "aws_cloudwatch_metric_alarm" "web_asg_cpu_alarm_up" {
  alarm_name                = "${var.project}_web_asg_cpu_alarm_up"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "75"
  insufficient_data_actions = []

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webserver_group.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = ["${aws_autoscaling_policy.web_asg_policy_up.arn}"]
}

#ASG Scale-down Policy
resource "aws_autoscaling_policy" "web_asg_policy_down" {
  name                   = "${var.project}_web_asg_policy_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.webserver_group.name
}

resource "aws_cloudwatch_metric_alarm" "web_asg_cpu_alarm_down" {
  alarm_name          = "${var.project}_web__asg_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "25"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webserver_group.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.web_asg_policy_down.arn]
}


#ASG Scale-up Policy based on memory
resource "aws_autoscaling_policy" "web_asg_policy_mem_up" {
  name                   = "${var.project}_web_asg_policy_mem_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.webserver_group.name
}

resource "aws_cloudwatch_metric_alarm" "web_asg_mem_alarm_up" {
  alarm_name          = "${var.project}_web_asg_mem_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ApplicationName = "${var.project}-Instance-ManagedBy-Terraform"
  }

  alarm_description = "This metric monitors EC2 instance memory utilization"
  alarm_actions     = [aws_autoscaling_policy.web_asg_policy_mem_up.arn]
}

#ASG Scale-down Policy based on memory
resource "aws_autoscaling_policy" "web_asg_policy_mem_down" {
  name                   = "${var.project}_web_asg_policy_mem_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.webserver_group.name
}

resource "aws_cloudwatch_metric_alarm" "web_asg_mem_alarm_down" {
  alarm_name          = "${var.project}_web_asg_mem_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    # let dimension be the name of webserver_group
    ApplicationName = "${var.project}-Instance-ManagedBy-Terraform"
    # AutoScalingGroupName = aws_autoscaling_group.webserver_group.name
  }

  alarm_description = "This metric monitors EC2 instance memory utilization"
  alarm_actions     = [aws_autoscaling_policy.web_asg_policy_mem_down.arn]
}

