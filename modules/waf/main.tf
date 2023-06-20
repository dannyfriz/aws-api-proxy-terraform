# Define un conjunto de direcciones IP sospechosas
resource "aws_wafv2_ip_set" "suspected_ips" {
  name               = "suspected-malicious-ips"
  description        = "Set of IP addresses suspected of malicious activity"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["192.0.2.44/32", "203.0.113.0/24"]
}

# Define una ACL web que utilizará las reglas definidas.
resource "aws_wafv2_web_acl" "waf_acl" {
  name        = var.waf_acl_name
  description = var.waf_acl_description
  scope       = "REGIONAL"

  default_action {
    block {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "DefaultVisibilityMetrics"
    sampled_requests_enabled   = true
  }
}

# Define la asociación entre la ACL y un recurso específico (en este caso, una API Gateway)
resource "aws_wafv2_web_acl_association" "waf_acl_association" {
  depends_on   = [aws_wafv2_web_acl.waf_acl]
  resource_arn = var.api_gateway_stage_arn
  web_acl_arn  = aws_wafv2_web_acl.waf_acl.arn
}

# Define un grupo de reglas WAF, que se refiere al conjunto de direcciones IP definido anteriormente.
resource "aws_wafv2_rule_group" "waf_rule_group" {
  depends_on = [aws_wafv2_ip_set.suspected_ips, aws_wafv2_web_acl_association.waf_acl_association]

  name        = "api-gateway-rule-group"
  description = "WAF Rule Group for protecting API Gateway from common threats"
  scope       = "REGIONAL"
  capacity    = 100

  # Regla de control de IP
  rule {
    name     = "IPControlRule"
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
      metric_name                = "IPControlRuleMetrics"
      sampled_requests_enabled   = true
    }
  }

  # Regla de control de ruta para /admin
  rule {
    name     = "PathControlRule"
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
      metric_name                = "PathControlRuleMetrics"
      sampled_requests_enabled   = true
    }
  }

  # Regla de control de solicitudes
  rule {
    name     = "RequestControlRule"
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
      metric_name                = "RequestControlRuleMetrics"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "api-gateway-rule-group-metrics"
    sampled_requests_enabled   = true
  }
}
