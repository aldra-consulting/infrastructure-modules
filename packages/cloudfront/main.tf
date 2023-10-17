# ------------------------------------------------------------------------------
# Module setup
# ------------------------------------------------------------------------------

terraform {
  backend "s3" {}
}

locals {
  environment              = var.environment
  namespace                = var.namespace
  tags                     = var.tags
  cloudfront_distributions = var.cloudfront_distributions
  allowed_methods = {
    API_GATEWAY = [
      "GET",
      "HEAD",
      "OPTIONS",
      "PUT",
      "POST",
      "PATCH",
      "DELETE",
    ]
  }
  cached_methods = {
    API_GATEWAY = [
      "GET",
      "HEAD",
    ]
  }
  cache_policy_id = {
    API_GATEWAY = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled (see https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html#managed-cache-policy-caching-disabled)
  }
  origin_request_policy_id = {
    API_GATEWAY = "216adef6-5c7f-47e4-b989-5492eafa07d3" # AllViewer (see https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-origin-request-policies.html#managed-origin-request-policy-all-viewer)
  }
  response_headers_policy_id = {
    API_GATEWAY = "e61eb60c-9c35-4d20-a928-2b84e02af89c" # CORS-and-SecurityHeadersPolicy ID (see https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html)
  }
  custom_origin_config = {
    API_GATEWAY = {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
}

provider "aws" {}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# ------------------------------------------------------------------------------
# Module configuration
# ------------------------------------------------------------------------------

data "aws_route53_zone" "this" {
  name = local.environment.project.domain_name
}

module "acm" {
  for_each = { for cloudfront_distribution in local.cloudfront_distributions : cloudfront_distribution.name => cloudfront_distribution }

  source = "terraform-aws-modules/acm/aws"

  providers = {
    aws = aws.us_east_1
  }

  zone_id = data.aws_route53_zone.this.zone_id

  domain_name = each.value.domain_name

  subject_alternative_names = [
    "*.${each.value.domain_name}",
  ]

  validation_method = "DNS"

  tags = local.tags
}

module "s3_bucket_apex_redirector" {
  for_each = { for cloudfront_distribution in local.cloudfront_distributions : cloudfront_distribution.name => cloudfront_distribution }

  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${local.namespace}-${each.value.name}-redirector"

  acl = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  website = {
    redirect_all_requests_to = {
      protocol  = "https"
      host_name = "www.${each.value.domain_name}"
    }
  }

  tags = local.tags
}

module "cloudfront_www" {
  for_each = { for cloudfront_distribution in local.cloudfront_distributions : cloudfront_distribution.name => cloudfront_distribution }

  source = "terraform-aws-modules/cloudfront/aws"

  aliases         = ["www.${each.value.domain_name}"]
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${local.namespace}-${each.value.name}-www-cloudfront-distribution"
  price_class     = "PriceClass_100"

  ordered_cache_behavior = tolist([
    for index, cache_behaviour in each.value.cache_behaviours : {
      allowed_methods = local.allowed_methods[cache_behaviour.type]
      cached_methods  = local.cached_methods[cache_behaviour.type]

      compress               = true
      viewer_protocol_policy = "redirect-to-https"
      use_forwarded_values   = false

      cache_policy_id            = local.cache_policy_id[cache_behaviour.type]
      origin_request_policy_id   = local.origin_request_policy_id[cache_behaviour.type]
      response_headers_policy_id = local.response_headers_policy_id[cache_behaviour.type]

      target_origin_id = cache_behaviour.origin.id
    } if cache_behaviour.path != null && cache_behaviour.path != "*"
  ])

  default_cache_behavior = element(tolist([
    for index, cache_behaviour in each.value.cache_behaviours : {
      allowed_methods = local.allowed_methods[cache_behaviour.type]
      cached_methods  = local.cached_methods[cache_behaviour.type]

      compress               = true
      viewer_protocol_policy = "redirect-to-https"
      use_forwarded_values   = false

      cache_policy_id            = local.cache_policy_id[cache_behaviour.type]
      origin_request_policy_id   = local.origin_request_policy_id[cache_behaviour.type]
      response_headers_policy_id = local.response_headers_policy_id[cache_behaviour.type]

      target_origin_id = cache_behaviour.origin.id
    } if cache_behaviour.path == null || cache_behaviour.path == "*"
  ]), 0)

  viewer_certificate = {
    acm_certificate_arn = module.acm[each.key].acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  geo_restriction = {
    restriction_type = "none"
  }

  origin = {
    for cache_behaviour in each.value.cache_behaviours : cache_behaviour.origin.id => {
      domain_name          = cache_behaviour.origin.domain_name
      custom_origin_config = local.custom_origin_config[cache_behaviour.type]
    }
  }

  tags = local.tags
}

module "cloudfront_apex" {
  for_each = { for cloudfront_distribution in local.cloudfront_distributions : cloudfront_distribution.name => cloudfront_distribution }

  source = "terraform-aws-modules/cloudfront/aws"

  aliases         = [each.value.domain_name]
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${local.namespace}-${each.value.name}-apex-cloudfront-distribution"
  price_class     = "PriceClass_100"

  default_cache_behavior = {
    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
      "PUT",
      "POST",
      "PATCH",
      "DELETE",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    use_forwarded_values   = false

    cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled (see https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html#managed-cache-policy-caching-disabled)
    origin_request_policy_id   = "b689b0a8-53d0-40ab-baf2-68738e2966ac" # AllViewerExceptHostHeader (see https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-origin-request-policies.html#managed-origin-request-policy-all-viewer-except-host-header)
    response_headers_policy_id = "e61eb60c-9c35-4d20-a928-2b84e02af89c" # CORS-and-SecurityHeadersPolicy ID (see https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html)

    target_origin_id = module.s3_bucket_apex_redirector[each.key].s3_bucket_id
  }

  viewer_certificate = {
    acm_certificate_arn = module.acm[each.key].acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  geo_restriction = {
    restriction_type = "none"
  }

  origin = {
    s3 = {
      origin_id   = module.s3_bucket_apex_redirector[each.key].s3_bucket_id
      domain_name = module.s3_bucket_apex_redirector[each.key].s3_bucket_website_endpoint
      custom_origin_config = {
        http_port              = "80"
        https_port             = "443"
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  tags = local.tags
}

resource "aws_route53_record" "www_api_gateway_route53_record" {
  for_each = { for cloudfront_distribution in local.cloudfront_distributions : cloudfront_distribution.name => cloudfront_distribution }

  zone_id = data.aws_route53_zone.this.zone_id
  name    = "www.${each.value.domain_name}"
  type    = "A"

  alias {
    name                   = module.cloudfront_www[each.key].cloudfront_distribution_domain_name
    zone_id                = module.cloudfront_www[each.key].cloudfront_distribution_hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "apex_api_gateway_route53_record" {
  for_each = { for cloudfront_distribution in local.cloudfront_distributions : cloudfront_distribution.name => cloudfront_distribution }

  zone_id = data.aws_route53_zone.this.zone_id
  name    = each.value.domain_name
  type    = "A"

  alias {
    name                   = module.cloudfront_apex[each.key].cloudfront_distribution_domain_name
    zone_id                = module.cloudfront_apex[each.key].cloudfront_distribution_hosted_zone_id
    evaluate_target_health = true
  }
}
