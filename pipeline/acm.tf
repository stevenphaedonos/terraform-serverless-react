# ACM resources must be in us-east-1 region in order to be used for CloudFront
resource "aws_acm_certificate" "domain_cert" {
  provider    = aws.us
  domain_name = var.domain
  subject_alternative_names = [
    "*.${var.domain}",
    "*.stage.${var.domain}",
  ]
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "domain_cert_validation" {
  provider        = aws.us
  certificate_arn = aws_acm_certificate.domain_cert.arn
  validation_record_fqdns = [
    aws_route53_record.prod_cert_validation.fqdn,
    aws_route53_record.stage_cert_validation.fqdn
  ]
}
