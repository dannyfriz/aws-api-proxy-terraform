resource "aws_wafv2_web_acl" "waf_acl" {
  name        = var.waf_acl_name
  description = var.waf_acl_description
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "IPControlRule"
    priority = 1
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    action {
      block {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPControlRuleMetrics"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "RuleControlRule"
    priority = 2
    statement {
      rule_group_reference_statement {
        arn = aws_wafv2_rule_group.waf_rule_group.arn
      }
    }
    action {
      block {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RuleControlRuleMetrics"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "DefaultVisibilityMetrics"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "waf_acl_association" {
  resource_arn = var.api_gateway_execution_arn
  web_acl_arn  = aws_wafv2_web_acl.waf_acl.arn
}

resource "aws_wafv2_rule_group" "waf_rule_group" {
  name        = "api-gateway-rule-group"
  description = "WAF Rule Group for protecting API Gateway from common threats"
  scope       = "REGIONAL"
  capacity    = 100

  rule {
    name     = "APISecurityRule"
    priority = 1

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.suspected_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "APISecurityRuleMetrics"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "api-gateway-rule-group-metrics"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_ip_set" "suspected_ips" {
  name               = "suspected-malicious-ips"
  description        = "Set of IP addresses suspected of malicious activity"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["192.0.2.44/32", "203.0.113.0/24"] 
}
