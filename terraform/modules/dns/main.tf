// We want AWS to host our zone so its nameservers can point to our Alb.
#DNS Configuration
#Get already , publicly configured Hosted Zone on Route53 - MUST EXIST

data "aws_route53_zone" "base_dns" {
  name = var.root_domain_name
  tags = {
    Name = "Cv-React-App_Zone"
  }
}
// This Route53 record will point at our CloudFront distribution.
resource "aws_route53_record" "root_record" {
  zone_id = data.aws_route53_zone.base_dns.zone_id
  name    = var.root_domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_record" {
  zone_id = data.aws_route53_zone.base_dns.zone_id
  name    = var.www_domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
