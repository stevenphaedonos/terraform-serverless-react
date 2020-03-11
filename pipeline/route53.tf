resource "aws_route53_zone" "hosted_zone" {
  name = "${var.domain}."

  tags = {
    Project     = var.project_name
    Environment = "prod"
  }
}

resource "aws_route53_record" "aws_caa_authorization" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = ""
  type    = "CAA"
  records = ["0 issue \"amazon.com\""]
  ttl     = 300
}

resource "aws_route53_record" "stage_cloudfront" {
  name    = "stage"
  type    = "A"
  zone_id = aws_route53_zone.hosted_zone.id

  alias {
    name                   = aws_cloudfront_distribution.stage_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.stage_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "stage_cert_validation" {
  name    = aws_acm_certificate.domain_cert.domain_validation_options[2].resource_record_name
  type    = aws_acm_certificate.domain_cert.domain_validation_options[2].resource_record_type
  zone_id = aws_route53_zone.hosted_zone.id
  records = [aws_acm_certificate.domain_cert.domain_validation_options[2].resource_record_value]
  ttl     = 60
}

resource "aws_route53_record" "prod_cloudfront" {
  name    = ""
  type    = "A"
  zone_id = aws_route53_zone.hosted_zone.id

  alias {
    name                   = aws_cloudfront_distribution.prod_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.prod_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "prod_cert_validation" {
  name    = aws_acm_certificate.domain_cert.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.domain_cert.domain_validation_options[0].resource_record_type
  zone_id = aws_route53_zone.hosted_zone.id
  records = [aws_acm_certificate.domain_cert.domain_validation_options[0].resource_record_value]
  ttl     = 60
}
