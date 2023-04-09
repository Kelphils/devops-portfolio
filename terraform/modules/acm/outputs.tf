output "acm_certificate_arn" {
  value       = aws_acm_certificate.certificate.arn
  description = "The ARN of the certificate"
}
