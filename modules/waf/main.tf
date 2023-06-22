# Define a set of suspicious IP addresses
resource "aws_wafv2_ip_set" "malicious_ips_set" {
  name               = "malicious-ips-set"
  description        = "Set of IP addresses suspected of malicious activity"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["192.0.2.44/32", "203.0.113.0/32"]
}

# Define a WAF rule group for malicious activity
resource "aws_wafv2_rule_group" "malicious_activity_rules" {
  name        = "malicious-activity-rule-group"
  description = "WAF Rule Group for Malicious Activity"
  scope       = "REGIONAL"
  capacity    = 100

  # IP control rule
  rule {
    name     = "BlockMaliciousIPs"
    priority = 1

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.malicious_ips_set.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockMaliciousIPsMetricsFromIPSet"
      sampled_requests_enabled   = true
    }
  }

  # Path control rule for /admin
  rule {
    name     = "BlockAdminPathAccess"
    priority = 2

    action {
      block {}
    }

    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "x-original-uri"
          }
        }
        positional_constraint = "STARTS_WITH"
        search_string         = "/admin"
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockAdminPathAccessMetricsFromByteMatch"
      sampled_requests_enabled   = true
    }
  }

  # Request control rule
  rule {
    name     = "BlockLargeRequests"
    priority = 3

    action {
      block {}
    }

    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "content-length"
          }
        }
        positional_constraint = "EXACTLY"
        search_string         = "1000000"
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockLargeRequestsMetricsFromByteMatch"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "MaliciousActivityRuleGroupMetrics"
    sampled_requests_enabled   = true
  }
}

# Define a WAF rule group for allowed activity
resource "aws_wafv2_rule_group" "allow_activity_rules" {
  name        = "allow-activity-rule-group"
  description = "WAF Rule Group for Allowed Activity"
  scope       = "REGIONAL"
  capacity    = 100

  # Rule to allow traffic to specified API Gateway
  rule {
    name     = "AllowSpecificAPIGateway"
    priority = 1

    action {
      allow {}
    }

    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "host"
          }
        }
        positional_constraint = "CONTAINS"
        search_string         = "amazonaws.com"
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowSpecificAPIGatewayMetrics"
      sampled_requests_enabled   = true
    }
  }

  # Rule to allow traffic from a specific domain
  rule {
    name     = "AllowSpecificAPI"
    priority = 2

    action {
      allow {}
    }

    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "host"
          }
        }
        positional_constraint = "CONTAINS"
        search_string         = var.api_uri
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowSpecificAPIMetrics"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "AllowActivityRuleGroupMetrics"
    sampled_requests_enabled   = true
  }
}

# Define a web ACL that will use the defined rules
resource "aws_wafv2_web_acl" "malicious_activity_acl" {
  name        = "malicious-activity-acl"
  scope       = "REGIONAL"

  default_action {
    block {}
  }

  # Rule to allow traffic to a specific domain origin
  rule {
    name     = "AllowSpecificOriginAPI"
    priority = 1

    action {
      allow {}
    }

    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "host"
          }
        }
        positional_constraint = "CONTAINS"
        search_string         = var.api_gateway_api_domain_name
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowSpecificOriginAPIMetrics"
      sampled_requests_enabled   = true
    }
  }

  # Rule Group
  rule {
    name     = "AllowActivityRules"
    priority = 2

    override_action {
      none {}
    }

    statement {
      rule_group_reference_statement {
        arn = aws_wafv2_rule_group.allow_activity_rules.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowActivityRulesMetricsFromRuleGroup"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "MaliciousActivityRules"
    priority = 3

    override_action {
      none {}
    }

    statement {
      rule_group_reference_statement {
        arn = aws_wafv2_rule_group.malicious_activity_rules.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "MaliciousActivityRulesMetricsFromRuleGroup"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "MaliciousActivityACLMetrics"
    sampled_requests_enabled   = true
  }
}

# Define the association between the ACL and a specific resource (in this case, an API Gateway)
resource "aws_wafv2_web_acl_association" "malicious_activity_acl_association" {
  resource_arn = var.api_gateway_stage_arn
  web_acl_arn  = aws_wafv2_web_acl.malicious_activity_acl.arn
}
resource "aws_s3_bucket" "waf_logs_bucket" {
  bucket = "waf-logs-bucket-${var.environment}"

  tags = {
    environment = var.environment
    name        = var.name
    project     = var.project
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "waf_logs_bucket_s3" {
  bucket = "aws-waf-logs-${random_id.bucket_suffix.hex}"

  tags = {
    environment = var.environment
    name        = var.name
    project     = var.project
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "waf_logs_bucket_lifecycle" {
  bucket = aws_s3_bucket.waf_logs_bucket_s3.id

  rule {
    id      = "waf-logs-lifecycle-rule"
    status  = "Enabled"

    noncurrent_version_transition {
      newer_noncurrent_versions = null
      noncurrent_days           = 30
      storage_class             = "STANDARD_IA"
    }

    noncurrent_version_transition {
      newer_noncurrent_versions = null
      noncurrent_days           = 60
      storage_class             = "GLACIER"
    }

    noncurrent_version_expiration {
      newer_noncurrent_versions = null
      noncurrent_days           = 90
    }
  }
}

resource "aws_cloudwatch_log_group" "waf_logs" {
  name              = "aws-waf-logs-${var.environment}"
  retention_in_days = 30
}

resource "aws_wafv2_web_acl_logging_configuration" "log_config" {
  log_destination_configs = [aws_s3_bucket.waf_logs_bucket_s3.arn]
  resource_arn            = aws_wafv2_web_acl.malicious_activity_acl.arn

  redacted_fields {
    single_header {
      name = "user-agent"
    }
  }

  redacted_fields {
    single_header {
      name = "referer"
    }
  }

  redacted_fields {
    single_header {
      name = "cookie"
    }
  }

  redacted_fields {
    single_header {
      name = "authorization"
    }
  }
}
