# run the command below to specify the path for configuration of the
# terraform state in S3 bucket with the DynamoDb table as the backend and encryption, locking enabled
# terraform init -backend-config=backend.hcl

locals {
  # Dynamic repo list
  deployment = {
    Repo-1 = {
      repo = "Kelphils/devops-portfolio"
      # codepipeline_name = "${module.codePipeline.codepipeline_name}"
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

module "codeBuild" {
  source         = "./modules/codeBuild"
  codebuild_role = module.iam.codebuild_role_arn
}

module "codePipeline" {
  source                           = "./modules/codePipeline"
  kms_key_arn                      = module.codeBuild.kms_alias_key_arn
  for_each                         = local.deployment
  repository_in                    = each.value.repo
  name_in                          = each.key
  codebuild_project_name           = module.codeBuild.codebuild_project_name
  codedeploy_app_name              = module.codeDeploy.codedeploy_app_name
  codedeploy_deployment_group_name = module.codeDeploy.codedeploy_group_name
  code_pipeline_role_arn           = module.iam.codepipeline_role_arn
}
