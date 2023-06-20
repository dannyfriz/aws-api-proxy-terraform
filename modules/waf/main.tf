# Define un conjunto de direcciones IP sospechosas
resource "aws_wafv2_ip_set" "malicious_ips_set" {
  name               = "malicious-ips-set"
  description        = "Set of IP addresses suspected of malicious activity"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["192.0.2.44/32", "203.0.113.0/24"]
}

# Define un grupo de reglas WAF
resource "aws_wafv2_rule_group" "malicious_activity_rules" {
  name        = "malicious-activity-rule-group"
  description = "WAF Rule Group for Malicious Activity"
  scope       = "REGIONAL"
  capacity    = 100

  # Regla de control de IP
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
      metric_name                = "BlockMaliciousIPsMetrics"
      sampled_requests_enabled   = true
    }
  }

  # Regla de control de ruta para /admin
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
      metric_name                = "BlockAdminPathAccessMetrics"
      sampled_requests_enabled   = true
    }
  }

  # Regla de control de solicitudes
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
      metric_name                = "BlockLargeRequestsMetrics"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "MaliciousActivityRuleGroupMetrics"
    sampled_requests_enabled   = true
  }
}

# Define una ACL web que utilizará las reglas definidas.
resource "aws_wafv2_web_acl" "malicious_activity_acl" {
  name        = "malicious-activity-acl"
  scope       = "REGIONAL"

  default_action {
    block {}
  }

  rule {
    name     = "MaliciousActivityRules"
    priority = 1

    override_action {
      count {}
    }

    statement {
      rule_group_reference_statement {
        arn = aws_wafv2_rule_group.malicious_activity_rules.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "MaliciousActivityRulesMetrics"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "MaliciousActivityACLMetrics"
    sampled_requests_enabled   = true
  }
}

# Define la asociación entre la ACL y un recurso específico (en este caso, una API Gateway)
resource "aws_wafv2_web_acl_association" "malicious_activity_acl_association" {
  resource_arn = var.api_gateway_stage_arn
  web_acl_arn  = aws_wafv2_web_acl.malicious_activity_acl.arn
}
