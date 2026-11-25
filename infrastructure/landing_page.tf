# Landing page: S3 static website behind CloudFront at var.landing_page_domain

data "aws_route53_zone" "platformoon" {
  name = var.hosted_zone_name
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

# S3 Bucket
resource "aws_s3_bucket" "landing_page" {
  bucket        = var.landing_page_domain
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "landing_page" {
  bucket = aws_s3_bucket.landing_page.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "landing_page" {
  bucket                  = aws_s3_bucket.landing_page.id
  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "landing_page" {
  bucket = aws_s3_bucket.landing_page.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowAll",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.landing_page.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.landing_page]
}

# TLS Certificate
resource "aws_acm_certificate" "landing_page" {
  provider          = aws.us_east_1
  domain_name       = var.landing_page_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "landing_page_certificate_validation" {
  zone_id = data.aws_route53_zone.platformoon.zone_id
  name    = tolist(aws_acm_certificate.landing_page.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.landing_page.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.landing_page.domain_validation_options)[0].resource_record_value]
  ttl     = 300
}

resource "aws_acm_certificate_validation" "landing_page" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.landing_page.arn
  validation_record_fqdns = [aws_route53_record.landing_page_certificate_validation.fqdn]
}

# CloudFront
resource "aws_cloudfront_distribution" "landing_page" {
  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2"
  price_class         = "PriceClass_All"
  default_root_object = "index.html"
  aliases             = [var.landing_page_domain]

  # WAF web ACL that CloudFront created with the distribution's security protections
  web_acl_id = "arn:aws:wafv2:us-east-1:555411961606:global/webacl/CreatedByCloudFront-46173a34/fb449541-ca95-4bef-adf2-df7471f780c0"

  origin {
    origin_id   = "${var.landing_page_domain}-website"
    domain_name = aws_s3_bucket_website_configuration.landing_page.website_endpoint

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "${var.landing_page_domain}-website"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.landing_page.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# DNS
resource "aws_route53_record" "landing_page_ipv4" {
  zone_id = data.aws_route53_zone.platformoon.zone_id
  name    = var.landing_page_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.landing_page.domain_name
    zone_id                = aws_cloudfront_distribution.landing_page.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "landing_page_ipv6" {
  zone_id = data.aws_route53_zone.platformoon.zone_id
  name    = var.landing_page_domain
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.landing_page.domain_name
    zone_id                = aws_cloudfront_distribution.landing_page.hosted_zone_id
    evaluate_target_health = false
  }
}

# GitHub Actions deployer (access key is created outside Terraform to keep it out of the state)
resource "aws_iam_user" "landing_page_deployer" {
  name          = var.landing_page_deployer_name
  force_destroy = true
}

resource "aws_iam_policy" "landing_page_deploy_policy" {
  name        = "TallyoLandingPageDeployPolicy"
  description = "Allows publishing the landing page to ${var.landing_page_domain}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject"],
        Resource = "${aws_s3_bucket.landing_page.arn}/*"
      },
      {
        Effect   = "Allow",
        Action   = ["cloudfront:CreateInvalidation"],
        Resource = aws_cloudfront_distribution.landing_page.arn
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_landing_page_deploy_policy" {
  user       = aws_iam_user.landing_page_deployer.name
  policy_arn = aws_iam_policy.landing_page_deploy_policy.arn
}
