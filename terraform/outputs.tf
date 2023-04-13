output "app-dns-url" {
  value       = module.dns.url
  description = "The domain name of the app"
}

# output "webserver_instance_ids" {
#   value       = module.webServer.ec2_instance_ids
#   description = "IDs of EC2 instances"
# }

output "codepipeline_name" {
  value = {
    for key, value in local.deployment :
    key => module.codePipeline[key].codepipeline_name
  }
  description = "Name of CodePipeline"
}

