output "url" {
  value       = aws_route53_record.root_record.fqdn
  description = "The URL of the record"
}
