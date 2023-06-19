output "waf_acl_arn" {
  description = "ARN del ACL de WAF"
  value       = aws_wafv2_web_acl.waf_acl.arn
}
