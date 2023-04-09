# run the command below to specify the path for configuration of the
# terraform state in S3 bucket with the DynamoDb table as the backend and encryption, locking enabled
# terraform init -backend-config=backend.hcl


module "acm" {
  source = "./modules/acm"
}

module "securityGroup" {
  source           = "./modules/securityGroup"
  alb_tls_cert_arn = module.acm.acm_certificate_arn
}

module "alb" {
  source              = "./modules/alb"
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
}

module "dns" {
  source       = "./modules/dns"
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}
