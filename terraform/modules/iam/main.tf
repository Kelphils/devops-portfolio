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
