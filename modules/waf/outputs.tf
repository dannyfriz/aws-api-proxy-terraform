output "waf_acl_arn" {
  description = "ARN of the WAF ACL"
  value       = aws_wafv2_web_acl.malicious_activity_acl.arn
}
