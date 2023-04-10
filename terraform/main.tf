# run the command below to specify the path for configuration of the
# terraform state in S3 bucket with the DynamoDb table as the backend and encryption, locking enabled
# terraform init -backend-config=backend.hcl

locals {
  # Dynamic repo list
  deployment = {
    Repo-1 = {
      repo = "GitHub-Account-Name/Repo-1-Name"
    }
    # Repo-2 = {
    #   repo = "GitHub-Account-Name/Repo-2-Name"
    # }

  }
}
module "acm" {
  source = "./modules/acm"
}

module "iam" {
  source = "./modules/iam"
}
module "securityGroup" {
  source           = "./modules/securityGroup"
  depends_on       = [module.acm]
  alb_tls_cert_arn = module.acm.acm_certificate_arn
}

module "alb" {
  source              = "./modules/alb"
  depends_on          = [module.acm]
  alb_tls_cert_arn    = module.acm.acm_certificate_arn
  alb_security_groups = module.securityGroup.alb_sg_id
}

module "targetGroup" {
  source       = "./modules/targetGroup"
  listener_arn = module.alb.listener_arn
}

module "webServer" {
  source = "./modules/webServer"
  #   alb_tls_cert_arn = module.acm.acm_certificate_arn
  aws_lb_target_group_arn = module.targetGroup.target_group_arn
  security_groups         = module.securityGroup.instance_sg_id
  instance_profile        = module.iam.cw_agent_instance_profile
}

module "dns" {
  source       = "./modules/dns"
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}

module "ci-cd-server" {
  source           = "./modules/ci-cd-server"
  security_groups  = module.securityGroup.instance_sg_id
  instance_profile = module.iam.codedeploy_instance_profile

}

module "codeDeploy" {
  source               = "./modules/codeDeploy"
  asg_name             = module.ci-cd-server.ci_cd_instance_ids
  code_deploy_role_arn = module.iam.codedeploy_role_arn
}
