output "name_record" {
  value = aws_route53_record.www.name
}

output "fqdn" {
  value = aws_route53_record.www.fqdn
}
